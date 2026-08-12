# ClashBox V2 periodic ClearConnections — latest analysis

Date: 2026-08-11, data through ~14:29 UTC. Device: HarmonyOS PC, bundle
`org.xbgroup.clashbox` (store V2 line), UI pid 30723, VPN pid 31314.

## TL;DR

The ~180.5 s wipe timer is an ArkTS timer in the ClashBox **UI process** and it
fires **if and only if the UI process is executing JavaScript**. Measured by
UI-process utime/stime (not inferred from window state):

- UI executing (window visible, or background keepalive held) → every grid
  epoch wipes all Mihomo trackers (RPC method 11 ClearConnections) → all
  long-lived flows get synchronized FIN.
- UI suspended (minimized here) → due fire-points are **skipped silently**;
  no wipe; the VPN extension keeps relaying traffic normally.
- On the next wake, the most recent deferred fire executes **immediately**
  (wipe lands within ~1 s of the first CPU tick).

## The A/B/A evidence (all timestamps UTC)

Steady grid while executing (both TUN fake-ip leg and 127.0.0.1:7890 leg die
within milliseconds of each other, FIN / rustls UnexpectedEof class):

    13:35:57.60  13:38:57.93  13:41:58.10  13:44:58.64  13:47:58.87
    13:50:59.60  13:54:00.27  13:57:01.17  14:00:01.33  14:03:01.54
    14:06:01.65  14:09:02.55  14:12:02.69  14:15:03.05

    spacing: 180.2–180.7 s (morning fit: 180.5004 s ± 0.5 s over 52 cycles;
    phase anchored ~3 s after VPN/core process start)

Minimize → suspend → wake sequence (3 s CPU sampling of pid 30723):

    14:16:54   UI CPU goes flat (0 ms/s) — window minimized
    14:18:43.6 grid fire-point passes — NO wipe (blocked by suspension)
    14:19:07.5 UI wakes (first CPU tick) → deferred wipe fires 14:19:07.55
    14:19:07–14:20:20 executing (~90–130 ms/s)
    14:20:20   flat again (minimized)
    14:22:08, 14:25:28 grid points pass — NO wipe (both blocked)
    14:28:38–41 UI wakes → deferred wipe fires 14:28:40.24

Earlier same-day confirmation: 13:07:23–13:14:04 the UI CPU was flat for 7+
minutes and probes crossed 4 predicted epochs untouched, while the VPN kept
working (pongs continuous through ClashBox TUN and mixed port).

Excluded as different failure class: 13:06:38–43 both legs died with TCP RST,
~5 s apart, and a brand-new connection was also reset — upstream/path blip,
not the grid bug (the grid bug is synchronized FIN within ≤15 ms).

## What this pins down

1. The caller is a periodic ArkTS timer in the V2 UI process (not the VPN
   extension, not the core, not the system).
2. It invokes RPC method 11 ClearConnections over clash_go.sock (method settled
   previously by two runtime discriminators: controller keep-alive survival +
   absence of the "RESTful API listening at" re-listen log at epochs).
3. Any UI-executing state drives it: foreground window, or background execution
   via a keepalive feature. Suspension stops it completely.
4. The wake-wipe behavior (deferred fire landing within ~1 s of wake) is
   characteristic of a suspended JS interval timer catching up on resume.

## Eliminated candidates

- Profile/subscription auto-update: connection-host logging across epochs
  shows zero subscription-URL fetches; the active profile is a local file://.
- LTS timers: no 180 s constant exists in public LTS source (all periodic tasks
  are 0.9/1/1.5/9 s page-scoped, or 60 s profile auto-update). The ~180 s
  timer is V2-added, app-level (fires regardless of which page is open).
- Window visibility per se: irrelevant except through its effect on UI-process
  execution.

## Open item: which V2 keepalive sustains it in the background

Candidates (V2 settings vocabulary, from the May 2026 settings export):
长时任务 (backgroundKeepTask), 模拟画中画 (backgroundPiPModel),
模拟音频 (BackgroundAudioService), 模拟定位 (backgroundLocateModel),
模拟下载 (backgroundDownModel), master switch EnableBackgrounder.

Bisection protocol (one change at a time, VPN left running):

1. Enable exactly one keepalive; minimize the window.
2. Observe ≥3 predicted epochs (~10 min):
   - UI CPU keeps growing + grid wipes continue → that feature sustains the
     timer.
   - UI CPU flat + wipes stop → it doesn't.
3. Disable again and confirm (ON→OFF→ON).

## Practical mitigation (validated)

To stop the wipes today: minimize the ClashBox window and keep all background
keepalive features off. The UI process suspends, the timer never fires, and
the VPN extension keeps forwarding normally. Caveat: any UI wake (opening the
window, or an enabled keepalive) fires the deferred wipe immediately.

## Upstream fix direction

In the V2 UI timer's callback, remove the routine ClearConnections call (or
replace it with selective removal of trackers that are actually dead). The
manual "clear connections" button must keep working. Nothing in LTS source,
Mihomo, or Codex should change.

## Instrumentation currently running

- Auto-restarting probe loops (TUN + 127.0.0.1:7890) logging every wipe with
  ms timestamps: `tmp/mihomo-standalone-k3X9q/epoch-watch-long-131718/`
- 3 s UI/VPN CPU sampler: `tmp/mihomo-standalone-k3X9q/ui-cpu-samples.log`
- Lifecycle hilog capture: `tmp/mihomo-standalone-k3X9q/lifecycle-clean.hilog`
- Timeline joiner: `tmp/mihomo-standalone-k3X9q/analyze-bisection.py`

## Related files

- `INVESTIGATION-2026-08-11-synchronized-fin.md` — full investigation report
- `VERIFICATION-PROTOCOL.md` — install/bisection protocol
- `UPSTREAM-ISSUE-DRAFT.md` — issue draft for xiaobaigroup/ClashBox
