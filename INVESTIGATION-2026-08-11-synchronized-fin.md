# ClashBox / Mihomo synchronized-FIN investigation — consolidated report

Date: 2026-08-11. All timestamps UTC. Device: HarmonyOS PC (HongMeng Kernel 1.12.0,
aarch64), unprivileged shell uid 20020228.

Original symptom (HarmonyOS Codex port):

    stream disconnected before completion:
    IO error: peer closed connection without sending TLS close_notify

## Headline conclusion

On a precise ~180.5-second wall-clock grid, the installed ClashBox (unpublished
V2 line) issues a one-shot RPC from its UI process to its embedded Mihomo core
over the private Unix socket `clash_go.sock`, which closes **every** connection
tracker in `statistic.DefaultManager`. Mihomo's bidirectional relay then closes
each application-facing connection with an orderly FIN (TUN-side via gVisor,
localhost-side via the mixed listener). The application sees `read()==0`,
`CLOSE_WAIT`, `SO_ERROR==0`, and — because Mihomo relays opaque TLS bytes and
never injects `close_notify` — rustls reports `UnexpectedEof`.

The wipe is **conditional on ClashBox running**. It is not caused by the
HarmonyOS VPN/TUN layer, Fake-IP, the physical network, the proxy node, the
remote endpoint, rustls, Tokio/mio, tungstenite, or the OHOS userspace.

The periodic caller exists only in the unpublished V2 code. Public ClashBox
source (LTS) contains the destructive RPC handler but **no automatic caller**.

---

## 1. Evidence timeline

### Morning epochs (prior session, ClashBox active)

06:18:28.145 · 06:30:30.702 · 06:42:32.968 · 07:54:44.797 · 08:00:45.970 ·
08:18:48.729 · 08:36:51.532 · 08:54:54.370 (+ tracker replacement bracketed
08:57:54.810–.992).

Least-squares fit (recomputed this session): **period 180.5004 s, every residual
within ±0.5 s over 52 cycles** — a software timer (e.g. ArkTS
`setInterval(180000)` with consistent per-cycle callback/scheduling drift), not
network jitter.

### This session's epochs (ClashBox active)

| Epoch | Cycle | What died |
| --- | --- | --- |
| 11:40:22.43–.47 | ~107 | 3 probe legs (TUN, ClashBox mixed :7890, standalone mihomo :17890), FIN within 15 ms |
| 11:46:22.41 | 109 | in-flight direct canary request (no long-lived flows existed) |
| 11:49:24.579–.581 | 110 | 3 probe legs, FIN within 2 ms |
| 11:52:25.411–.414 | 111 | 2 probe legs, 16.8 s after connecting (killed at first epoch after start) |

### Decisive A/B (same device, same physical network, same core version string)

| Window | ClashBox | Grid cycles | Wipes |
| --- | --- | --- | --- |
| 10:51–11:25 | OFF | 11 full cycles | **0** (2 tracker IDs stable, no EOF) |
| from 11:25:18 | ON | every observed cycle | **every epoch wipes all flows** |

Standalone setup: upstream mihomo v1.19.27 built on-device (harmonybrew
go1.26.5, CGO off; version string shows 1.10.0 only because ldflags unset —
`git describe` = v1.19.27), running the user's `Ultimate.yaml` with ports moved
(mixed 17890, socks 17891, controller 127.0.0.1:19090, DNS 127.0.0.1:15353).
Probes: `hmos_wss_probe` (codex-websocket-client example, branch ohos-build of
jerry-271828/codex), `--proxy http://127.0.0.1:17890` vs direct,
`wss://ws.postman-echo.com/raw`, 3 s pings, full transport diagnostics.

### The 11:25:18 anomaly — fully explained (NOT environmental)

All three standalone legs (including the genuinely direct one bound to
192.168.3.20) died simultaneously at 11:25:18.54, the direct leg with
ECONNRESET. `/proc` mtimes: ClashBox UI process created **11:25:12.873**, VPN
extension process **11:25:16.281**. Flows died when the VPN finished coming up
and the default network moved to `vpn-tun` — the normal "VPN establishment
invalidates existing sockets" behavior. Grid proximity (−0.65 s) was
coincidence.

## 2. What happens at every epoch (all observed together)

- Controller tracker table goes `connections: null` 10–65 ms **before** app
  FINs; entirely new tracker IDs appear immediately after.
- Every app socket: `POLLIN|POLLOUT|POLLRDHUP`, `MSG_PEEK==0`, `SO_ERROR==0`,
  `TCP_INFO.state==CLOSE_WAIT`, `read()==0` → rustls `UnexpectedEof`.
- 5-second short-request canary succeeds **through** epochs — only pre-existing
  flows die; an in-flight connect at the epoch is killed.
- Quiet-period captures (morning): exactly one new `clash_go.sock` RPC
  connection at the epoch, the only RPC in a 118 s window (observed twice).
  (With the UI active the background RPC rate is ~2/s, so this signature is
  only detectable in quiet periods.)
- **No** HarmonyOS network-layer event at epochs: no available/lost/capability
  callbacks, no route/address changes, `vpn-tun` counters continue, hilog shows
  only steady background noise.
- Both ClashBox processes stay alive; UI/VPN appear healthy.
- Ordering proof that "table empties before app FIN" is *propagation*, not
  necessarily RPC causality: at 11:40:22 my standalone mihomo's table emptied
  at .432 purely because ClashBox killed its TUN-captured outbound; its relays
  then FINed my probes at .463–.470.

## 3. Mechanism, source-verified (upstream mihomo v1.19.27)

- `tunnel/statistic/tracker.go:110-113` — `tcpTracker.Close()` removes itself
  from the manager and closes the wrapped **outbound** connection.
- `tunnel/tunnel.go:613-622` — that tracker is the outbound half of the relay;
  the TUN/mixed-listener connection is the inbound half.
- `common/net/sing.go:69-92` — `Relay` closes both connections when either copy
  direction ends → orderly FIN toward the application.

ClashBox wrapper paths (public master `1fdc47eb`):

- RPC dispatch: `proxy_core/src/flclash/ipc.go` — method 11 `ClearConnections`
  (`:146-148`), method 12 `Load` (`:149-153`); JSON framing, one request per
  connection, `{"method":N,"params":[...]}`.
- Global close: `handleCloseConnectionsUnLock`,
  `proxy_core/src/flclash/hub.go:247-269` — iterates every tracker, `Close()`.
- Non-patch apply: `proxy_core/src/flclash/common.go:349-366` — calls the same
  close before `hub.ApplyConfig` even when config bytes are unchanged.
- Public callers: `ClearConnections` only from the manual clean button
  (`entry/src/main/ets/components/More/Connect.ets:147-157` via
  `ClashViewModel.ets:313-315`). Non-patch load from init/recovery
  (`ClashViewModel.ets:421`, `:537`). **No periodic caller in public source.**

## 4. Trigger: method 11 vs method 12

Favors **method 11 (`ClearConnections`)**:

- An idle HTTP/1.1 keep-alive connection to the external controller
  (`127.0.0.1:9090`) survived an epoch by 67+ s. A public-style non-patch Load
  would call `hub.ApplyConfig` → `route.ReCreateServer` (`hub/hub.go:43-60`) →
  `httpServer.Close()` (`hub/route/server.go:160-164`), and pinned
  `metacubex/http` v0.1.6 `Server.Close` closes **all** active connections
  including idle ones (verified `server.go:3082-3101`). Caveat: the unpublished
  V2 core could have changed apply behavior.
- No core-internal periodic wipe exists in the OHOS core or upstream (only
  per-provider close on provider init and the controller DELETE API; the 1 s
  manager ticker is traffic sampling). Empirically the standalone core ran 11
  clean cycles.

## 5. Exonerated (each with direct evidence)

- rustls / Tokio / mio / tungstenite / codex-websocket-client — DockerHarmony
  native OHOS probes survived 1800 s twice (GH runs 31474572903, 31477521209,
  repo jerry-271828/codex branch ohos-build).
- OHOS userspace + Rust stack generally — same runs.
- echo.websocket.org — kills connections at ~600 s **connection age** itself
  (two staggered connections died 34 s apart at 605.5 s age); excluded from
  probes as a confound.
- Physical network / Wi-Fi / ISP — 33-min clean standalone window on the same
  network, and no-flow-deaths while ClashBox was off.
- HarmonyOS VPN/TUN/netstack — no network callbacks at epochs; TUN counters
  continuous; routes/addresses stable; processes stable.
- Fake-IP — localhost CONNECT bypasses it and still fails (Phase 1 A/B).
- Proxy node / endpoint — two nodes reproduce; postman direct also dies when
  ClashBox is on.
- The hybrid musl/OHOS codex target — native `aarch64-unknown-linux-ohos`
  probes both reproduce (with ClashBox) and survive (without ClashBox).

## 6. Installed-version vs public-source parity

- Installed: `org.xbgroup.clashbox`, most likely the unpublished V2 line
  (2.0.x, AppGallery-pushed); embedded controller reports Mihomo 1.19.27.
  Package metadata inaccessible to this shell (`bm`/`aa` denied).
- Public: bundle `org.xbgroup.clashboxLTS`, latest release 1.7.4 (`f78de056`);
  audited master `1fdc47eb` (2026-07-05). No parity established; all statements
  about the installed binary are empirical.
- Public ClashBox LTS CI core is built from `xfz347/Clash.Meta` ohos branch
  (reports 1.10.0-based) — also not the installed V2 core.

## 7. Narrowest responsible component

**The ClashBox-V2 ArkTS wrapper's periodic (~180.5 s) RPC into the embedded
core over `clash_go.sock`, which wipes `statistic.DefaultManager` — most
probably `ClearConnections` (method 11).** The destructive core path itself
(`handleCloseConnectionsUnLock`) is shared with public source; the periodic
caller is V2-only.

## 8. Instrumented build (prepared; needs one GUI step)

Branch `diag/close-trigger-instrumented` on `jerry-271828/ClashBox`, commit
`ae41bbd5` (base `ci/ohos-core-build` + minimal patch, 49 ins / 10 del).
CI run 31484200385 succeeded. The patch logs, via the mihomo log stream
(`[NETDIAG]` prefix, RFC3339-nano + monotonic):

- `ipc_request_received method=N` for every core RPC;
- `apply_config_begin is_patch=...`;
- `close_all_connections_begin/completed reason=rpc_clear_connections |
  apply_config_non_patch` with before/after tracker counts.

One wipe epoch with this build settles the method number. Note: the HAP is
signed with the OpenHarmony **test key** (no signing secrets configured) —
retail HarmonyOS may refuse it; if so, configure the six `HAP_SIGNING_*`
secrets with Huawei developer material and re-run CI. Bundle is
`org.xbgroup.clashboxLTS` (coexists with installed V2; only one VPN at a time).
If the wipe does **not** reproduce on LTS, that alone proves V2-specificity.

## 9. Fix direction and validation

The fix belongs to the unpublished V2 wrapper: stop issuing the periodic
connection-clearing RPC (or, if method 12, use patch-load / skip tracker close
when the config is unchanged). Nothing to fix in public LTS, Mihomo, or Codex.

- Report to `xiaobaigroup/ClashBox`; complements open issue #158 (long-run VPN
  stability; its stall symptoms are a different failure mode of the same
  wrapper layer).
- User-side check: toggle any periodic maintenance/cleanup-style V2 setting;
  if the 180.5 s grid disappears, the caller is identified functionally.
- Validation after fix: four-flow probe set (TUN + mixed-port × 2 endpoints,
  3 s pings) survives ≥3 consecutive predicted epochs; controller tracker IDs
  unchanged across epochs; pongs continuous. Keep the Codex transport
  diagnostics patch until this passes.

## 10. Practical side effect observed

With ClashBox active, any download/stream lasting longer than the current
~180.5 s grid remainder is killed (GitHub artifact downloads repeatedly died
mid-stream with "unexpected EOF" — the bug truncating its own evidence).

## 11. Environment/build gotchas recorded (device)

- cargo target dir must be ext4 (`/data/storage/el2/base/cache/...`); sharefs
  gives ETXTBSY on build scripts.
- aws-lc-sys 0.39 on `aarch64-unknown-linux-ohos`: set
  `OHOS_SDK_NATIVE=/storage/Users/currentUser/.harmonybrew/opt/ohos-sdk/native`
  and delete stale `target/release/build/aws-lc-sys-*` (its rerun-if-env list
  omits OHOS_SDK_NATIVE), else cmake skips asm and the link fails on
  `aws_lc_0_39_0_*_neon` symbols.
- go build default output runs as-is; do NOT re-sign with binary-sign-tool;
  `-buildmode=pie` segfaults.
- `GOPROXY=https://goproxy.cn,direct` (default proxy.golang.org unreachable).
- git clone of github.com is flaky (SSL EOF); `gh api` tarball/artifacts work.

## 11b. Second-session addendum (2026-08-11 PM UTC)

### RPC method: 11 (ClearConnections), two independent runtime discriminators

Both rely only on the V2 core behaving like public v1.19.27 in two unremarkable
code paths:

1. **Controller keep-alive survival** (prior session): an idle HTTP/1.1
   keep-alive connection to `127.0.0.1:9090` survived an epoch by 67+ s.
   `hub.ApplyConfig` → `route.ReCreateServer` → `httpServer.Close()`, and
   pinned `metacubex/http` v0.1.6 `Server.Close` closes **all** active
   connections (`server.go:3082-3101`). A non-patch Load would have killed it.
2. **No controller re-listen log at the epoch**: mihomo logs
   `RESTful API listening at: ...` at INFO on every `ReCreateServer`
   (`hub/route/server.go:174`). The captured core debug/info stream covering
   the 08:54:54.370 epoch (2778 lines, 08:52:55–08:56:00, 180 info lines)
   contains **zero** such lines → no `ApplyConfig` → no non-patch Load.

So the periodic RPC is `ClearConnections` (method 11), whose only public caller
is the manual UI clean button — i.e. **the periodic caller is V2-specific
code**. Note `ReCreateMixed/Socks/...` return early when the address is
unchanged (`listener/listener.go:119-125`), so inbound listeners would NOT
change under a Load — the controller is the discriminating side effect.

### Grid phase anchors to the ClashBox instance start

- ClashBox was restarted at 12:31:55 (UI) / 12:32:46 (VPN) UTC (`/proc` mtimes).
  The next observed wipe was 12:50:52.65 — 1086.3 s ≈ 6 × 180.5004 s after
  ~12:32:49.6 (VPN process + ~3 s core init). The periodic task's phase
  therefore starts near core start, not at a global wall-clock constant.
- Under the previous instance (started 11:25:12/16), wipes were observed at
  every cycle that had live flows (cycles 5, 7, 8, 9).
- Under the new instance, the wipe at cycle 6 (12:50:52) occurred, then cycles
  7 (12:53:53) and 8 (12:56:53) did **not** wipe live probes — the caller's
  activation is conditional on some state that changed around 12:51 (candidate:
  UI/foreground state or a feature toggle; UI-lifecycle hilog capture in
  progress to correlate).

### No-install observation limits (documented dead ends)

- `/proc/net/tcp(6)` is permission-denied in this sandbox (listener-inode watch
  impossible); `/proc/net/unix` remains readable.
- `clash_go.sock` lives in the ClashBox mount namespace
  (`/data/storage/el2/base/haps/entry/files/` is per-app); direct RPC
  connection/sniffing from this shell is impossible.

### The periodic caller only runs while the ClashBox UI process executes

- Instance B (started 12:32): the last grid-signature wipe was 12:50:52.65
  (synchronized FIN, 40 ms spread). Since then, through ≥4 predicted grid
  cycles, auto-restarting probes on BOTH paths (TUN fake-ip + :7890) survived —
  verified still ClashBox-mediated (172.19.0.1 / 198.18.0.69).
- During the silent window the UI process (pid 30723) shows **zero CPU growth**
  (`/proc` utime/stime flat across 7+ minutes) — its JS timers are not running
  (backgrounded without an active keepalive).
- During the morning grid epochs, the UI process was executing (constant
  AceStateMgmt render noise in hilog at 08:39–08:40, and the 11:25 instance's
  wipe window 11:40–11:52 covers the user's active session).
- Therefore the caller is a UI-process ArkTS timer gated by process execution
  (foreground or background-keepalive such as 长时任务/模拟画中画). This makes
  the keepalive/PiP/background-run toggles the top bisection candidates and
  explains why the bug appears "always on" for normal users (they run ClashBox
  with background keepalive enabled) yet vanishes when the UI process is
  suspended.
- A separate 13:06:38–43 event killed both long-lived legs with TCP **RST**,
  staggered ~5 s, and also reset a brand-new connection — different signature
  (not synchronized FIN), classified as an upstream/node/path blip, not the
  grid bug.

### Live A/B on 2026-08-11 PM (user present, no setting changes by us)

Wipe epochs observed by the auto-restarting probe loops (both legs die within
ms, FIN/UnexpectedEof class = ClearConnections signature):

    12:50:52.65  (6 x 180.5004 s after the 12:32:49.6 instance-start anchor)
    13:22:12.99  (transition-period wake)
    13:34:02.53  (transition-period wake)
    13:35:57.60  then 13:38:57.93, 13:41:58.10, 13:44:58.64, 13:47:58.87,
    13:50:59.60, 13:54:00.27  (steady ~180.3 s grid, UI executing)

UI-process (pid 30723) CPU via /proc utime/stime:

    13:07:23 - 13:14:04   utime/stime frozen (0 jiffies in >7 min) -> probes
                          crossed 4 predicted epochs with NO wipe
    ~13:35 onward          ~5% CPU sustained (1 s text render loop + ~3 RPC/s
                          LocalSocket churn visible in hilog) -> grid fires
                          every ~180.3 s

Conclusion: the caller is an app-level ArkTS ~180 s timer in the V2 **UI
process** that runs iff the UI process executes JS (foreground window open —
on HarmonyOS PC an unfocused open window still executes — or a background
keepalive: 长时任务 / 模拟画中画 / 模拟音频 / 模拟定位 held). In the morning
the UI was executing under a keepalive (light RPC rate, no main-page polling);
in the afternoon it was foreground. Both states wipe. Suspended UI → no wipe
and the VPN extension keeps relaying normally (probes ponged through the whole
silent window).

### V2 settings surface (from the May 2026 V2 settings export)

`/storage/Users/currentUser/Download/org.xbgroup.clashbox/ClashBoxConfig_2026-05-15_07-39-57.json`
(oldVersionCode=2000021) names the V2 feature toggles:

    uiSettings: EnableBackgrounder, backgroundKeepTask (长时任务),
        backgroundPiPModel (模拟画中画), BackgroundAudioService (模拟音频),
        backgroundLocateModel (模拟定位), backgroundDownModel (模拟下载, LTS),
        EnabledNotice / EnabledPermanentNotice / EnabledStatusNotice /
        EnabledCoexistNotice (常驻/状态通知)
    appSettings: enableConnect (连接管理页), enableRequest (请求记录页),
        autoStart, autoCheckUpdate, accessControl ...
    configList: 6 profiles; the then-active one is a LOCAL file (file://),
        others are URL subscriptions

All background keepalives were False in that May export; current on-device
state is not directly readable (sandbox). No 180000/3-minute constant exists
anywhere in public LTS source (searched); LTS periodic tasks are 0.9 s / 1 s /
1.5 s / 9 s (page-scoped) and 60 s (profile auto-update) — the ~180 s timer is
V2-added.

## 12. Evidence locations

- This session: `/storage/Users/currentUser/tmp/mihomo-standalone-k3X9q/`
  (`SESSION-NOTES.md`, `evidence-20260811T105128Z/`, `evidence2-…/`,
  `run-control.sh`, `run-extended.sh`, `monitor-standalone.cjs`,
  `config-standalone.yaml`, `mihomo-upstream`, `mihomo-ohos`, probe binary in
  `/data/storage/el2/base/cache/codex-target/release/examples/hmos_wss_probe`).
- Prior session: `/storage/Users/currentUser/tmp/clashbox-ab-20260811-gHQGwT/`
  (`RESULTS.md`, `CLASHBOX_SOURCE_AUDIT.md`, both diagnostic patches, all raw
  evidence dirs).
- Instrumented build checkout: `/storage/Users/currentUser/tmp/hap-diag-build/`
  (artifact download still retrying in background at report time).
- Public source trees: `…/tmp/ClashBox-public-4pekUE`,
  `…/tmp/mihomo-v1.19.27-BcBuZP`, `…/tmp/clash-meta-ohos-uGsj44`.
