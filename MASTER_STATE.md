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


## Workflow fix — 2026-10-14

First collector bootstrap found **2 DLTB installations** on the user's PC, so the old strict resolver stopped before collection.

Fix applied:
- commands/_common.ps1 now prefers the DLTB installation belonging to the **currently running** DyingLightGame_TheBeast_x64_rwdi.exe process.
- If the game is not running and multiple installs remain ambiguous, the command stops safely and prints the candidates instead of guessing.
- User does not need a new bootstrap ZIP; rerunning the same CMD pulls this fix automatically.

Next action remains: run 1_COLLECTOR.cmd with the intended DLTB copy open.


## Baseline collector PASS — 2026-10-14 11:19

Run: `data/runs/20261014_111919/`

Confirmed active install:
- `C:\Program Files (x86)\Steam\steamapps\common\Dying Light The Beast`
- Process running: yes
- PID at collection: 39872
- Working set: ~4.81 GB

Confirmed game build:
- `DyingLightGame_TheBeast_x64_rwdi.exe`
  - size 1,493,568
  - SHA256 `B74298062BB000253FD3D6F25C8A8319F147E13FD7B7B7A51D9205CF51D123E5`
- `gamedll_ph_x64_rwdi.dll`
  - size 61,847,104
  - SHA256 `DDB68C8F87BA2AFD0E561B2D1ADB9235467C29069FB1CD1619DB81E1056378EB`

Important: this is the SAME gamedll hash already proven in the Night Sovereign work. Known RVAs from that project therefore belong to this exact build, although no no-clip RVA is assumed yet.

Active gameplay DLL base during this run:
- `gamedll_ph_x64_rwdi.dll = 0x7FFC4A050000`

Loaded mod layer reached `data7.pak`. Current `data7.pak` SHA256:
- `625CE44FC2B396238CC78A02C08AA75608E933E6F9FAFFAF74349A4B44C2F69D`

Runtime contamination note:
- `TrSpeedHack_x64.dll` from FLiNGTrainer was loaded during this baseline.
- This does NOT matter for the next disk/script inspection, but later memory-behavior comparisons should be done without unrelated trainer hooks if exact behavior matters.

## Strong no-clip lead

Public research shows DLTB already contains developer shortcut behavior. A current Nexus mod named "Restore Developer Shortcuts" reports a native toggle:
- Y = Noclip
- Pause/Break = Free Camera
- Scroll Lock = TPP
- F1 = camera-position teleport
- PgUp/PgDown = vertical free-camera movement

Separate public keybind documentation confirms DLTB keyboard actions are configured in:
- `scripts/inputs/inputs_keyboard.scr`

Do NOT copy/redistribute the Nexus author's asset. We will independently inspect the user's native/effective `inputs_keyboard.scr` and reconstruct the minimum change from the game's own script.

## Current phase

Phase 1 — native developer-shortcut discovery.

### Next action

Run the same `1_COLLECTOR.cmd` again after the remote collector update.

The next collector must upload ONLY small line-numbered snippets from:
- vanilla data0 `scripts/inputs/inputs_keyboard.scr`
- effective highest-priority `inputs_keyboard.scr`
- matching `scripts/inputs/inputenums.def` if present

Search targets:
- noclip / clip
- EKey__Y
- free camera / camera
- TPP / third person
- teleport
- debug / developer / ghost / collision
- Pause / Scroll Lock / F1 / PgUp / PgDown
- commented AddAction lines around those hits

No save dump. No full script upload. No memory scan yet.


## Input hotkey collector PASS — 2026-10-14 11:23

Run: `data/runs/20261014_112317/`

Confirmed from the user's own game files:

### inputs_keyboard.scr
- Effective source is still `data0.pak`; GH1 currently does not override this file.
- Native line 102 is ACTIVE, not commented:
  - `AddAction(_ACTION_DEVELOPER_MENU, EInputTarget_Module, EInputDevice_Keyboard, false, EKey__MULTIPLY, false, false);`
- Therefore NumPad `*` is a native developer-menu action candidate in this exact build.

### inputenums.def
Native key enums confirmed:
- `EKey__Y = 0x15`
- `EKey__F1 = 0x3B`
- `EKey__SCROLL = 0x46`
- `EKey__PAUSE = 0xC5`

The targeted input-file scan did NOT expose a literal noclip/freecam action name. So do not invent an action identifier yet.

## Decision

Do not build POC 1 yet.

Next smallest step:
1. User can manually press NumPad `*` once in-game to see whether the native developer menu opens. This requires no restart and changes nothing.
2. In parallel, expand the collector only across script-like entries for exact developer/no-clip/free-camera action strings and references to `_ACTION_DEVELOPER_MENU`.
3. If scripts still contain no direct action name, scan only ASCII/UTF-16 strings from the exact gamedll build for noclip/freecam/developer command names before any hook work.


## POC_01_DEV_MENU_F10

- User keyboard: 75%, no numpad.
- Native developer menu bind: EKey__MULTIPLY.
- User selected F10.
- Current candidate in mod/current changes only _ACTION_DEVELOPER_MENU to EKey__F10.
- Apply requires DLTB closed; then restart game and press F10 once.
- 2_CLEAN.cmd restores the exact pre-POC data7.pak.
