# POC_01_DEV_MENU_F10

Purpose: prove the game's already-active native developer-menu action can be reached from the user's 75% keyboard.

APPLY:
- reads the currently effective scripts/inputs/inputs_keyboard.scr from data0-data7;
- changes only _ACTION_DEVELOPER_MENU from EKey__MULTIPLY (NumPad *) to EKey__F10;
- writes only that override into data7.pak while preserving every other existing data7 entry;
- saves an exact pre-POC data7 backup locally for 2_CLEAN.cmd.

Test:
1. Close DLTB.
2. Run 3_APPLY.cmd.
3. Start DLTB normally.
4. Press F10 once.
5. Report: developer menu / nothing / other UI.

This does not enable noclip yet. It proves access to the native developer path.
