# ClashBox periodic-wipe — remaining verification protocol (manual steps)

Automated evidence collection has reached the limit of what the unprivileged
shell can observe. The steps below require GUI access to the device.

## A. What is already established (no further action needed)

1. With ClashBox OFF: standalone mihomo + probes survive 11+ full grid cycles.
2. With ClashBox ON: wipes occur on a ~180.5004 s grid, phase-anchored ~3 s
   after the VPN/core process start.
3. The periodic RPC is ClearConnections (method 11) with high confidence:
   - an idle controller keep-alive connection survived an epoch (a non-patch
     Load would have closed it via httpServer.Close);
   - no "RESTful API listening at" log line at the epoch (a non-patch Load
     would have emitted one via ReCreateServer).
4. The periodic caller does not exist in public LTS source → V2-specific.
5. Under the newest instance the wipe fired at 12:50:52 (≈6 cycles after the
   12:32:46 VPN start) and then stopped firing at 12:53:53/12:56:53 — the
   caller's activation is conditional (see D).

## B. Optional but decisive: install the instrumented LTS build

Purpose: (a) prove public LTS does not wipe (V2-specificity by experiment, not
just by source audit); (b) if it does wipe, the [NETDIAG] log names the method.

1. Get the HAP: GitHub Actions run 31484200385 (jerry-271828/ClashBox, branch
   diag/close-trigger-instrumented), artifact `ClashBox-openharmony-test-signed-hap`.
   (Local copy may be incomplete — downloads die at wipe epochs; use a
   resumable downloader, or download while VPN is off.)
2. Install: open the .hap in Files. It is signed with the OpenHarmony test key.
   If installation is refused, add Huawei developer signing material as the six
   `HAP_SIGNING_*` repo secrets and re-run the workflow (docs/ci-hap-signing.md).
3. Import any working profile, start the VPN (installed V2 must be stopped
   first — one VPN at a time).
4. Watch the core log (the wrapper exposes the mihomo log stream; or capture
   hilog) for lines containing `[NETDIAG]`:
   - if NO `close_all_connections_begin` appears across ≥5 predicted epochs →
     LTS does not wipe → periodic caller is V2-only (expected);
   - if it appears, the preceding `ipc_request_received method=N` names the
     method and the reason string names the path.

## C. V2 settings bisection (A/B/A)

The wipe grid restarts its phase when ClashBox restarts. Use that: after each
settings change, fully stop and start ClashBox, note the VPN process start
moment, and predict epochs as start+~3 s + n·180.5004 s.

For EACH candidate below: disable it → restart ClashBox → keep ≥2 long-lived
WSS probes (TUN + 127.0.0.1:7890) running → watch ≥5 predicted epochs
(~15 min). If wipes stop, re-enable and confirm they return (A/B/A).

Candidate order (most plausible first, given the README notes that 核心恢复 is
auto-enabled by 后台运行-模拟画中画):

1. 后台运行 / 模拟画中画 (Background run / simulated PiP) and any 核心恢复
   (core recovery) option.
2. 订阅/配置自动更新 (profile auto-update) — set to off, or a long interval.
3. 通知/实况窗 (permanent notification / LiveView) toggles.
4. 长时后台任务/模拟下载/模拟定位 (other background-keepalive modes).
5. Any 连接管理/自动清理/网络优化-style toggle present only in V2.

The epoch recorder (`run-epoch-watch.sh`) automates the detection: it keeps
auto-restarting probes through both paths and logs every wipe with ms
timestamps; just leave it running during the bisection.

## D. Live hypothesis under test (as of 12:58 UTC)

The caller fires every ~180.5 s only while some condition holds (it held
11:40–11:52 and at 12:50:52, then stopped). The lifecycle hilog capture
(`epoch-watch-*/clashbox-lifecycle.hilog`) timestamps UI activity of the
ClashBox process; correlate the next active/inactive transition with what the
user was doing (app foreground/background, PiP shown/closed, screen on/off).

## E. Upstream report

File to xiaobaigroup/ClashBox referencing issue #158; include:
- the grid fit (180.5004 s, ±0.5 s over 52 cycles);
- the OFF/ON A/B (11 clean cycles vs every-epoch wipes);
- the two method-11 discriminators;
- the phase-anchoring to instance start;
- this protocol's bisection outcome once known.
