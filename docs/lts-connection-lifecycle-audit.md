# LTS connection-lifecycle audit

Base: public ClashBox LTS, `master` @ `1fdc47eb9b3bdb715fb04c4b44e1d5238faf83e0`
(app code identical in `ci/ohos-core-build`; only CI/build metadata differs).

Question: does public LTS contain any **automatic/periodic** caller that closes
all active Mihomo trackers?

Answer: **No.** Every destructive path is either manual or a deliberate
profile-switch/recovery action. There is no timer, watchdog, lifecycle
callback, or background task in LTS that invokes a global connection close.

## Destructive primitives (core wrapper, Go)

| Path | Effect |
| --- | --- |
| `proxy_core/src/flclash/ipc.go:146-148` — RPC 11 `ClearConnections` → `handleCloseConnections()` | closes every tracker |
| `proxy_core/src/flclash/hub.go:247-269` — `handleCloseConnectionsUnLock` | iterates `statistic.DefaultManager`, `Tracker.Close()` |
| `proxy_core/src/flclash/common.go:349-366` — `applyConfig` with `is-patch=false` | calls `handleCloseConnectionsUnLock` before `hub.ApplyConfig` |
| `proxy_core/src/flclash/ipc.go:142-145` — RPC 10 `CloseConnection` | single tracker (manual per-item close) |

## All ArkTS callers of those primitives

| Caller | File | Trigger | Class |
| --- | --- | --- | --- |
| `ClashViewModel.clearConnections` ← clean button | `components/More/Connect.ets:147-157` | user taps "clear connections" | **manual, keep** |
| non-patch `loadConfig(false)` | `entryability/ClashViewModel.ets:525` (`initProfile`) | app startup, no flows exist | harmless |
| non-patch `loadConfig(false)` | `entryability/ClashViewModel.ets:413` (`ReStartVpn`) | genuine core recovery (VPN restarts anyway) | intentional |
| non-patch `loadConfig(false)` | `components/Home/FavoriteConfiguration.ets:59` | user taps a favorite profile | deliberate profile switch |
| non-patch `loadConfig(false)` | `pages/ConfigurationPage.ets:752` | user loads a profile | deliberate profile switch |
| patch `loadConfig(true)` (no close) | `pages/HomePage.ets:433`, `entryability/EntryAbility.ets:277`, `components/More/Resources.ets:207` | mode switch / card init / resource update | non-destructive |

## Automatic paths checked and cleared

- `ConfigAutoUpdateService` (60 s `setInterval`): downloads and saves due URL
  profiles, then emits `FetchProfile` — the handler only refreshes the UI
  profile list (`pages/Index.ets:1125-1127`). **No core reload.**
- Core-recovery `setInterval(1000)` (`entryability/EntryAbility.ets:481`):
  fires `ChangeCore`+`ReStartVpn` only when `socketProxy.active == false`
  (private RPC connect failure). Not periodic in healthy operation.
- All page timers (0.9 s duration display, 1 s traffic, 1.5 s notification,
  9 s connections-page query): query-only RPCs, cleared on page disappear.
- No `180000`/`3 * 60`/3-minute constant anywhere in the tree.

## Conclusion

Public LTS needs **no behavioral patch** for the periodic-wipe bug: the V2
~180.5 s automatic `ClearConnections` caller does not exist here. This branch
therefore ships the LTS feature set unmodified; validation focuses on proving
long-lived connections survive under this build.
