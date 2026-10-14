# REMOTE REQUEST

Current remote task: INPUT_ACTION_DISCOVERY_1B

Collector:
- Run the SAME 1_COLLECTOR.cmd again.
- Game can remain open. No restart.
- Scan only scripts/inputs/* across data0-data7 for developer/no-clip/freecam/camera/teleport/debug/TPP action strings.
- Also do a tiny targeted ASCII string probe of the exact gamedll for noclip/freecam/developer/collision/ghost terms.
- Upload only small text reports.
- Do not upload full scripts, saves, DLLs, or memory dumps.

Manual zero-risk test:
- While in-game, press NumPad * once.
- Report whether a developer menu appears, nothing happens, or another UI opens.

Apply:
- No POC yet. Wait for this collector result unless the native developer menu directly exposes noclip.

Monitor:
- Do not run yet.

Clean:
- No candidate installed.

MASTER STATE RULE:
Update MASTER_STATE.md before creating POC 1.
