# Native Developer Hotkey Scan 窶・20261014_112317

Target: independently inspect the game's own input scripts. No third-party mod assets copied.

## data0 vanilla inputs_keyboard.scr
- total lines: 1024
- raw matches: 3

[BEGIN SNIPPET]
  100:             //AddAction(_ACTION_MF_ROLLBACK,                      EInputTarget_Module, EInputDevice_Keyboard, false, EKey__SPACE_, false, false);
  101:             //AddAction(_ACTION_MF_QUIT,                          EInputTarget_Module, EInputDevice_Keyboard, false, EKey__ESCAPE, false, false);
  102:             AddAction(_ACTION_DEVELOPER_MENU,                   EInputTarget_Module, EInputDevice_Keyboard, false, EKey__MULTIPLY, false, false);
  103:             AddAction(_ACTION_RELOAD,                           EInputTarget_Player, EInputDevice_Keyboard, false, EKey__R, false, false);
  104: 			AddAction(_ACTION_ROPE_HOOK_USE_WITHOUT_EQUIPPING,  EInputTarget_Player, EInputDevice_Keyboard, false, EKey__LMENU, false, false);
[END SNIPPET]

[BEGIN SNIPPET]
  261:             AddAction(_ACTION_HANDBRAKE, 				EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__SPACE_, 		false, false);
  262: 			AddAction(_ACTION_VEHICLE_LEAVE,			EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__F, 			false, false) { HoldTime(0.2); }
  263: 			AddAction(_ACTION_VEHICLE_CHANGE_CAMERA, 	EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__V, 			false, false);
  264:             AddAction(_ACTION_TURN_VEHICLE_LEFT, 		EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__A, 			false, false);
  265:             AddAction(_ACTION_TURN_VEHICLE_RIGHT, 		EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__D, 			false, false);        
[END SNIPPET]

[BEGIN SNIPPET]
  319:             
  320: 			AddAction(_ACTION_DIALOG_SKIP, 						EInputTarget_Module, EInputDevice_Keyboard, false, EKey__SPACE_, false, false);
  321:             AddAction(_ACTION_DIALOG_PLAYER_CAMERA_ZOOM,        EInputTarget_Player, EInputDevice_Mouse, false, EMouse__BUTTON_2, false, false);
  322:             
  323:             AddAction(_ACTION_MULTILOOT_TAKE,                   EInputTarget_GUI, EInputDevice_Keyboard, false, EKey__F, false, false);
[END SNIPPET]


## Effective keyboard source
- slot: data0.pak
- pak: C:\Program Files (x86)\Steam\steamapps\common\Dying Light The Beast\ph_ft\source\data0.pak

## effective inputs_keyboard.scr
- total lines: 1024
- raw matches: 3

[BEGIN SNIPPET]
  100:             //AddAction(_ACTION_MF_ROLLBACK,                      EInputTarget_Module, EInputDevice_Keyboard, false, EKey__SPACE_, false, false);
  101:             //AddAction(_ACTION_MF_QUIT,                          EInputTarget_Module, EInputDevice_Keyboard, false, EKey__ESCAPE, false, false);
  102:             AddAction(_ACTION_DEVELOPER_MENU,                   EInputTarget_Module, EInputDevice_Keyboard, false, EKey__MULTIPLY, false, false);
  103:             AddAction(_ACTION_RELOAD,                           EInputTarget_Player, EInputDevice_Keyboard, false, EKey__R, false, false);
  104: 			AddAction(_ACTION_ROPE_HOOK_USE_WITHOUT_EQUIPPING,  EInputTarget_Player, EInputDevice_Keyboard, false, EKey__LMENU, false, false);
[END SNIPPET]

[BEGIN SNIPPET]
  261:             AddAction(_ACTION_HANDBRAKE, 				EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__SPACE_, 		false, false);
  262: 			AddAction(_ACTION_VEHICLE_LEAVE,			EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__F, 			false, false) { HoldTime(0.2); }
  263: 			AddAction(_ACTION_VEHICLE_CHANGE_CAMERA, 	EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__V, 			false, false);
  264:             AddAction(_ACTION_TURN_VEHICLE_LEFT, 		EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__A, 			false, false);
  265:             AddAction(_ACTION_TURN_VEHICLE_RIGHT, 		EInputTarget_Player, EInputDevice_Keyboard, false, 	EKey__D, 			false, false);        
[END SNIPPET]

[BEGIN SNIPPET]
  319:             
  320: 			AddAction(_ACTION_DIALOG_SKIP, 						EInputTarget_Module, EInputDevice_Keyboard, false, EKey__SPACE_, false, false);
  321:             AddAction(_ACTION_DIALOG_PLAYER_CAMERA_ZOOM,        EInputTarget_Player, EInputDevice_Mouse, false, EMouse__BUTTON_2, false, false);
  322:             
  323:             AddAction(_ACTION_MULTILOOT_TAKE,                   EInputTarget_GUI, EInputDevice_Keyboard, false, EKey__F, false, false);
[END SNIPPET]


## data0 vanilla inputenums.def
- total lines: 227
- raw matches: 5

[BEGIN SNIPPET]
   21: export int EKey__R              = 0x13;
   22: export int EKey__T              = 0x14;
   23: export int EKey__Y              = 0x15;
   24: export int EKey__U              = 0x16;
   25: export int EKey__I              = 0x17;
[END SNIPPET]

[BEGIN SNIPPET]
   59: export int EKey__SPACE_         = 0x39;
   60: export int EKey__CAPITAL        = 0x3A;
   61: export int EKey__F1             = 0x3B;
   62: export int EKey__F2             = 0x3C;
   63: export int EKey__F3             = 0x3D;
[END SNIPPET]

[BEGIN SNIPPET]
   70: export int EKey__F10            = 0x44;
   71: export int EKey__NUMLOCK        = 0x45;
   72: export int EKey__SCROLL         = 0x46;         // Scroll Lock
   73: export int EKey__NUMPAD7        = 0x47;
   74: export int EKey__NUMPAD8        = 0x48;
[END SNIPPET]

[BEGIN SNIPPET]
   94: export int EKey__CONVERT        = 0x79;         // Japanese keyboard
   95: export int EKey__NOCONVERT      = 0x7B;         // Japanese keyboard
   96: export int EKey__YEN            = 0x7D;         // Japanese keyboard
   97: export int EKey__ABNT_C2        = 0x7E;         // Numpad '.' on Portugese (Brazilian) keyboards
   98: export int EKey__NUMPADEQUALS   = 0x8D;         // '=' on numeric keypad (NEC PC98)
[END SNIPPET]

[BEGIN SNIPPET]
  119: export int EKey__SYSRQ          = 0xB7;
  120: export int EKey__RMENU          = 0xB8;         // right Alt 
  121: export int EKey__PAUSE          = 0xC5;         // Pause 
  122: export int EKey__HOME           = 0xC7;         // Home on arrow keypad 
  123: export int EKey__UP_            = 0xC8;         // UpArrow on arrow keypad 
[END SNIPPET]


## Effective enum source
- slot: data0.pak
- pak: C:\Program Files (x86)\Steam\steamapps\common\Dying Light The Beast\ph_ft\source\data0.pak

## effective inputenums.def
- total lines: 227
- raw matches: 5

[BEGIN SNIPPET]
   21: export int EKey__R              = 0x13;
   22: export int EKey__T              = 0x14;
   23: export int EKey__Y              = 0x15;
   24: export int EKey__U              = 0x16;
   25: export int EKey__I              = 0x17;
[END SNIPPET]

[BEGIN SNIPPET]
   59: export int EKey__SPACE_         = 0x39;
   60: export int EKey__CAPITAL        = 0x3A;
   61: export int EKey__F1             = 0x3B;
   62: export int EKey__F2             = 0x3C;
   63: export int EKey__F3             = 0x3D;
[END SNIPPET]

[BEGIN SNIPPET]
   70: export int EKey__F10            = 0x44;
   71: export int EKey__NUMLOCK        = 0x45;
   72: export int EKey__SCROLL         = 0x46;         // Scroll Lock
   73: export int EKey__NUMPAD7        = 0x47;
   74: export int EKey__NUMPAD8        = 0x48;
[END SNIPPET]

[BEGIN SNIPPET]
   94: export int EKey__CONVERT        = 0x79;         // Japanese keyboard
   95: export int EKey__NOCONVERT      = 0x7B;         // Japanese keyboard
   96: export int EKey__YEN            = 0x7D;         // Japanese keyboard
   97: export int EKey__ABNT_C2        = 0x7E;         // Numpad '.' on Portugese (Brazilian) keyboards
   98: export int EKey__NUMPADEQUALS   = 0x8D;         // '=' on numeric keypad (NEC PC98)
[END SNIPPET]

[BEGIN SNIPPET]
  119: export int EKey__SYSRQ          = 0xB7;
  120: export int EKey__RMENU          = 0xB8;         // right Alt 
  121: export int EKey__PAUSE          = 0xC5;         // Pause 
  122: export int EKey__HOME           = 0xC7;         // Home on arrow keypad 
  123: export int EKey__UP_            = 0xC8;         // UpArrow on arrow keypad 
[END SNIPPET]



