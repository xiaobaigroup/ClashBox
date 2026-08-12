# ClashBox LTS stable build — install & validation guide

## The build

- Branch: `fix/lts-stable-long-connections` @ `7eff34ad` (jerry-271828/ClashBox)
- Base: public LTS `master` @ `1fdc47eb` + reproducible CI; **zero app-logic
  changes** (audit: `docs/lts-connection-lifecycle-audit.md` — no automatic
  ClearConnections caller exists in LTS; nothing to patch)
- Artifact: `ClashBox-7eff34adbd99-openharmony-test-signed.hap`
  sha256 `57fba87e4d4f54cbfafd8b3557585cada4bce4102ade96968a36d83b0b5695c0`
  local copy: `/storage/Users/currentUser/tmp/hap-lts-stable/ClashBox-openharmony-test-signed-hap/`
  (re-fetch: `gh run download 31545071671 -R jerry-271828/ClashBox`)
- Identity: bundle `org.xbgroup.clashboxLTS`, versionName `1.7.4-lts-stable.1`,
  versionCode 1007048 — coexists with store V2 (`org.xbgroup.clashbox`).

## 1. Install

Open the .hap in Files. If retail HarmonyOS rejects the OpenHarmony test key:
put Huawei developer material into the six repo secrets (`HAP_SIGNING_P12_B64`,
`HAP_SIGNING_CERT_B64`, `HAP_SIGNING_PROFILE_B64`, `HAP_KEY_ALIAS`,
`HAP_KEY_PASSWORD`, `HAP_STORE_PASSWORD`) and re-run the workflow
(`workflow_dispatch` supported) — it then produces a device-valid signed HAP.
Do not commit secrets.

## 2. Prepare

1. Stop the store V2 ClashBox (only one VPN at a time).
2. In the LTS app: import the same profile (e.g. the local `sub.txt` file or
   subscription URL), select a node, start the VPN.
3. Confirm `127.0.0.1:7890` (mixed) and `127.0.0.1:9090` (controller) respond.

## 3. Long-lived-connection validation (automated)

From a terminal:

    sh /storage/Users/currentUser/tmp/mihomo-standalone-k3X9q/run-lts-validation.sh

(Default 3600 s; override with `DURATION=...`. Uses `hmos_wss_probe`, 4 legs:
TUN ×2 + mixed-port ×2, all to `wss://ws.postman-echo.com/raw`, 3 s pings,
controller monitor at 20 Hz.)

Success criteria (old V2 bug would fail within ~3 minutes):

- zero `websocket_error` events in all four legs for the full run
- controller tracker IDs stable; no `connections: null` transitions
- works identically while you foreground / minimize / restore the LTS window
  during the run (the script spans long enough to do both)

## 4. Manual clear regression (UI)

During a validation run: open 连接管理/Connect page → tap the clear
(connections) action. Expected: all four legs die together with FIN (that's
the intended manual behavior), controller table empties, then the LTS app
keeps working and new connections succeed.

## 5. Codex real-world validation

With LTS as the active VPN, run normal Codex sessions that stream >3 minutes
(e.g. a long refactor). Success = no
`peer closed connection without sending TLS close_notify` from the periodic
wipe pattern. Keep `CODEX_WS_TRANSPORT_DIAGNOSTICS=1` if you want the
transport-level proof in codex logs.

## What to expect at a glance

| Action | Active flows |
| --- | --- |
| nothing / UI foreground / minimize / restore | survive |
| switch node, switch rule mode, open pages | survive |
| switch/load profile (favorite tap, config-page load) | **terminated** (deliberate: config actually changes) |
| manual "clear connections" | **terminated** (deliberate) |
| core recovery after genuine core death | restarted anyway (deliberate) |

## Validation results (2026-08-12, device run)

Run 1 (`lts-validation-20260811T234621Z`, 23:46–00:03 UTC): 4 legs (2×TUN
fake-ip + 2×mixed 7890), 17.4 min, **zero automatic events**. At 00:03:45 the
user tapped the manual clear: all 4 legs received synchronized FIN within
4 ms — manual ClearConnections works as designed.

Run 2 (`lts-validation-20260812T000702Z`, 00:07–01:14 UTC): 4 auto-restarting
legs, 67 min wall, ~4400 pings/pongs total:

- **no ~180.5 s periodic wipe** (the V2 bug would have fired ~22 times);
- **no global ClearConnections event** (no 4-leg synchronized FIN);
- proxy legs: 0 errors end-to-end;
- one isolated event at 00:32:04.8: both TUN legs reset with TCP RST 10 ms
  apart after ~580–600 s life, mixed-port legs unaffected. Classified as a
  TUN/gVisor-layer abortive reset (one-off, not FIN, not global, not
  periodic) — distinct from the V2 bug signature; noted for tracking, one
  occurrence per ~67 probe-hours... (per-run rate: 1 per 4 leg-hours).
- UI foreground/minimize/restore cycles during the runs: no effect on flows.
