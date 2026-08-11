# ClashBox LTS stable build (long-lived connections)

This branch (`fix/lts-stable-long-connections`) packages the **public ClashBox
LTS** line as a stable replacement for the unpublished store V2 build.

## Why

The store V2 build (`org.xbgroup.clashbox`, 2.0.x) periodically wipes all
active connections: a UI-process ArkTS timer fires about every 180.5 s while
the UI runtime is executing and invokes RPC `ClearConnections` (method 11) on
the embedded core. Every active TCP/WebSocket flow — TUN/Fake-IP and localhost
mixed-port alike — then receives an orderly FIN within the same millisecond
window. Details: `INVESTIGATION-2026-08-11-synchronized-fin.md` (not part of
upstream source).

Public LTS contains the destructive `ClearConnections` handler only behind the
**manual** "clear connections" action and has no automatic caller
(audit: `docs/lts-connection-lifecycle-audit.md`). No behavioral patch is
required; this build deliberately changes nothing in the app logic.

## What this build is

- Source: public LTS `master` @ `1fdc47eb` + the reproducible-build CI from
  `ci/ohos-core-build` (vendored `xb_components`, pinned core/gVisor/Go
  toolchain, OpenHarmony test-key or `HAP_SIGNING_*` secret signing).
- Bundle: `org.xbgroup.clashboxLTS` — coexists with store V2; run only one
  VPN at a time.
- Version identity: `1.7.4-lts-stable.1` (versionCode 1007048).
- Instrumented variant for RPC/close-event tracing lives separately on
  `diag/close-trigger-instrumented` and is not part of this build.

## Validation focus

Long-lived WSS/TCP flows must survive indefinitely across UI foreground,
minimize/restore, and background use; manual "clear connections" must still
work. See the validation section of the investigation notes.
