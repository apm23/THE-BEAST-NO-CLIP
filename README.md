# THE-BEAST-NO-CLIP

Remote-first development workspace for Dying Light: The Beast no-clip research.

Keep four tiny CMD launchers on the user's PC forever. The real collector/apply/clean/monitor logic lives in this repository and can be changed remotely.

## Local commands

- 1_COLLECTOR.cmd — collect requested data and upload it.
- 2_CLEAN.cmd — clean/restore the active failed candidate.
- 3_APPLY.cmd — apply the current candidate.
- 4_MONITOR.cmd — run the current live monitor and upload its log.

Each CMD pulls the newest main branch before running.

## Recommended local tools

Use Git for Windows plus GitHub CLI (gh). No custom desktop app is required. The first collector/monitor run can open the normal GitHub browser login through gh auth login. After that, uploads are automatic.

Read MASTER_STATE.md first. It is the canonical project state and prevents repeating old work.
