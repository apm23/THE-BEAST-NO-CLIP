# MASTER STATE — THE BEAST NO-CLIP

Last updated: 2026-10-14

## Goal

Build a reliable No-Clip feature for Dying Light: The Beast, then integrate the final working version into the user's GH1 mod collection.

## Workflow contract

The local machine keeps four permanent bootstrap commands:

1. 1_COLLECTOR.cmd — pulls the latest collector logic, collects only the data currently requested, and uploads it into data/runs/.
2. 2_CLEAN.cmd — pulls the latest clean logic and removes/restores the currently installed failed candidate.
3. 3_APPLY.cmd — pulls the latest apply logic and installs the current candidate from mod/current/.
4. 4_MONITOR.cmd — pulls the latest monitor logic, monitors the live game, and uploads results into monitor/runs/.

The CMD launchers should almost never change. Real behavior lives in commands/*.ps1 so it can be edited remotely between tests.

## Canonical folders

- commands/ — remote command logic.
- data/runs/ — collector uploads.
- monitor/runs/ — live-monitor uploads.
- mod/current/ — only the candidate being tested now.
- mod/trash/ — failed candidates. Never delete a failed candidate just because it failed; preserve useful addresses, signatures, code, crash boundaries, and observations.
- state/ — small machine-readable state/workflow notes.
- MASTER_STATE.md — canonical project state. Read this before deciding the next test.

## Known DLTB environment

- Steam AppID: 3008130
- Process: DyingLightGame_TheBeast_x64_rwdi.exe
- Main gameplay DLL: gamedll_ph_x64_rwdi.dll
- Platform: Windows x64 / Steam.
- Existing GH1 content must never be overwritten blindly.

## Research rules

- Prefer small targeted collectors over broad dumps.
- Avoid repeated game restarts.
- No descriptor BFS / giant graph crawls.
- Never do large memory copies inside a game-thread hook.
- Failed candidates go to mod/trash/, not deletion.
- Every meaningful test result updates MASTER_STATE before the next research branch.
- Collector/monitor uploads sanitize the Windows username and do not upload save files unless explicitly requested.

## No-Clip status

Phase 0 — workflow bootstrap.

No movement/physics hook has been selected yet.

## Next action

1. Install the four bootstrap CMD files.
2. Run 1_COLLECTOR.cmd.
3. Read the newest data/runs folder.
4. Update MASTER_STATE with confirmed build/module information.
5. Choose the smallest first no-clip POC.

## Result log

- 2026-10-14: Repository initialized.
- 2026-10-14: Remote-first four-command workflow requested.
- 2026-10-14: MASTER STATE plus structured data/monitor/mod/trash layout defined.
