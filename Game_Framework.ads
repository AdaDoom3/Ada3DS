--TODO:
--fix sound array and finish sdl_mixer
--sdl.mouse
--sdl.rwops
--ensure smooth keyboard/mouse input
--test ALL sound
--fix resize
--isolate all event related framework out of main
--put opengl stuff in
--CLEAN IT UP!
--COMMENT IT UP!

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Gnat.OS_Lib;           use Gnat.OS_Lib;
with SDL.Mouse;             use SDL.Mouse;
with SDL.RWops;             use SDL.RWops;
with System;
with System.Address_To_Access_Conversions;
with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with Interfaces.C.Pointers;
with Interfaces.C.Extensions;
package Game_Framework is
	type Framework_Boolean
		is new Interfaces.C.int;
	type Event_Type
		is new Interfaces.Unsigned_8;
	for Event_Type'Size
		use 8;
	type Key_Modifier
		is mod 2**32;
		pragma Convention (C, Key_Modifier);
	type Key
		is new Interfaces.C.int;
	type Initialization_Flag
		is mod 2**32;
		pragma Convention (C, Initialization_Flag);
	type Surface_Flags
		is mod 2 ** 32;
		for Surface_Flags'Size use 32;
	type GLattr
		is new Interfaces.C.int;
	type Active_State
		is mod 2**8;
	for Active_State'Size
		use 8;
	type Format_Flag
		is mod 2**16;
		pragma Convention (C, Format_Flag);
	type Format_Flag_ptr 
		is access Format_Flag;
		pragma Convention (C, Format_Flag_ptr);
	APPMOUSEFOCUS : constant Active_State := 16#01#;
	APPINPUTFOCUS : constant Active_State := 16#02#;
	APPACTIVE     : constant Active_State := 16#04#;
	MAX_SOUNDS                  : CONSTANT Integer := 4;
	DEFAULT_RESOLUTION_WIDTH    : CONSTANT Short_Integer := 800;
	DEFAULT_RESOLUTION_HEIGHT   : CONSTANT Short_Integer := 800;
	DEFAULT_FRAME_RATE          : CONSTANT Short_Integer := 60;
	DEFAULT_BITS_PER_PIXEL      : CONSTANT Short_Integer := 8;
	FRAMEWORK_FALSE             : constant Framework_Boolean := 0;
	FRAMEWORK_TRUE              : constant Framework_Boolean := 1;
	FRAMEWORK_PRESSED           : constant := 16#01#;
	FRAMEWORK_RELEASED          : constant := 16#00#;
	FLAG_INITIALIZE_TIMER       : CONSTANT Initialization_Flag := 16#00000001#;
	FLAG_INITIALIZE_AUDIO       : CONSTANT Initialization_Flag := 16#00000010#;
	FLAG_INITIALIZE_VIDEO       : CONSTANT Initialization_Flag := 16#00000020#;
	FLAG_INITIALIZE_CDROM       : CONSTANT Initialization_Flag := 16#00000100#;
	FLAG_INITIALIZE_NOPARACHUTE : CONSTANT Initialization_Flag := 16#00100000#;
	FLAG_INITIALIZE_EVENTTHREAD : CONSTANT Initialization_Flag := 16#01000000#;
	FLAG_INITIALIZE_EVERYTHING  : CONSTANT Initialization_Flag := 16#0000FFFF#;
	AUDIO_U8                    : CONSTANT Format_Flag := 16#0008#;
	AUDIO_S8                    : CONSTANT Format_Flag := 16#8008#;
	AUDIO_U16LSB                : CONSTANT Format_Flag := 16#0010#;
	AUDIO_S16LSB                : CONSTANT Format_Flag := 16#8010#;
	AUDIO_U16MSB                : CONSTANT Format_Flag := 16#1010#;
	AUDIO_S16MSB                : CONSTANT Format_Flag := 16#9010#;
	AUDIO_U16                   : CONSTANT Format_Flag := AUDIO_U16LSB;
	AUDIO_S16                   : CONSTANT Format_Flag := AUDIO_S16LSB;
	SWSURFACE                   : constant Surface_Flags := 16#00000000#;
	HWSURFACE                   : constant Surface_Flags := 16#00000001#;
	ASYNCBLIT                   : constant Surface_Flags := 16#00000004#;
	ANYFORMAT                   : constant Surface_Flags := 16#10000000#;
	HWPALETTE                   : constant Surface_Flags := 16#20000000#;
	DOUBLEBUF                   : constant Surface_Flags := 16#40000000#;
	FULLSCREEN                  : constant Surface_Flags := 16#80000000#;
	OPENGL                      : constant Surface_Flags := 16#00000002#;
	OPENGLBLIT                  : constant Surface_Flags := 16#0000000A#;
	RESIZABLE                   : constant Surface_Flags := 16#00000010#;
	NOFRAME                     : constant Surface_Flags := 16#00000020#;
	HWACCEL                     : constant Surface_Flags := 16#00000100#;
	SRCCOLORKEY                 : constant Surface_Flags := 16#00001000#;
	RLEACCELOK                  : constant Surface_Flags := 16#00002000#;
	RLEACCEL                    : constant Surface_Flags := 16#00004000#;
	SRCALPHA                    : constant Surface_Flags := 16#00010000#;
	PREALLOC                    : constant Surface_Flags := 16#01000000#;
	GL_RED_SIZE                 : constant GLattr :=  0;
	GL_GREEN_SIZE               : constant GLattr :=  1;
	GL_BLUE_SIZE                : constant GLattr :=  2;
	GL_ALPHA_SIZE               : constant GLattr :=  3;
	GL_BUFFER_SIZE              : constant GLattr :=  4;
	GL_DOUBLEBUFFER             : constant GLattr :=  5;
	GL_DEPTH_SIZE               : constant GLattr :=  6;
	GL_STENCIL_SIZE             : constant GLattr :=  7;
	GL_ACCUM_RED_SIZE           : constant GLattr :=  8;
	GL_ACCUM_GREEN_SIZE         : constant GLattr :=  9;
	GL_ACCUM_BLUE_SIZE        : constant GLattr := 10;
	GL_ACCUM_ALPHA_SIZE       : constant GLattr := 11;
	LOGPAL                    : constant := 16#01#;
	PHYSPAL                   : constant := 16#02#;
	NOEVENT                   : constant Event_Type :=  0;
	ISACTIVEEVENT             : constant Event_Type :=  1;
	KEYDOWN                   : constant Event_Type :=  2;
	KEYUP                     : constant Event_Type :=  3;
	MOUSEMOTION               : constant Event_Type :=  4;
	MOUSEBUTTONDOWN           : constant Event_Type :=  5;
	MOUSEBUTTONUP             : constant Event_Type :=  6;
	JOYAXISMOTION             : constant Event_Type :=  7;
	JOYBALLMOTION             : constant Event_Type :=  8;
	JOYHATMOTION              : constant Event_Type :=  9;
	JOYBUTTONDOWN             : constant Event_Type := 10;
	JOYBUTTONUP               : constant Event_Type := 11;
	QUIT                      : constant Event_Type := 12;
	ISSYSWMEVENT              : constant Event_Type := 13;
	EVENT_RESERVEDA           : constant Event_Type := 14;
	EVENT_RESERVEDB           : constant Event_Type := 15;
	VIDEORESIZE               : constant Event_Type := 16;
	EVENT_RESERVED1           : constant Event_Type := 17;
	EVENT_RESERVED2           : constant Event_Type := 18;
	EVENT_RESERVED3           : constant Event_Type := 19;
	EVENT_RESERVED4           : constant Event_Type := 20;
	EVENT_RESERVED5           : constant Event_Type := 21;
	EVENT_RESERVED6           : constant Event_Type := 22;
	EVENT_RESERVED7           : constant Event_Type := 23;
	ISUSEREVENT               : constant Event_Type := 24;
	NUMEVENTS                 : constant Event_Type := 32;
	KEY_UNKNOWN               : CONSTANT Key :=   0;
	KEY_FIRST                 : CONSTANT Key :=   0;
	KEY_BACKSPACE             : CONSTANT Key :=   8;
	KEY_TAB                   : CONSTANT Key :=   9;
	KEY_CLEAR                 : CONSTANT Key :=  12;
	KEY_RETURN                : CONSTANT Key :=  13;
	KEY_PAUSE                 : CONSTANT Key :=  19;
	KEY_ESCAPE                : CONSTANT Key :=  27;
	KEY_SPACE                 : CONSTANT Key :=  32;
	KEY_EXCLAIM               : CONSTANT Key :=  33;
	KEY_QUOTEDBL              : CONSTANT Key :=  34;
	KEY_HASH                  : CONSTANT Key :=  35;
	KEY_DOLLAR                : CONSTANT Key :=  36;
	KEY_AMPERSAND             : CONSTANT Key :=  38;
	KEY_QUOTE                 : CONSTANT Key :=  39;
	KEY_LEFTPAREN             : CONSTANT Key :=  40;
	KEY_RIGHTPAREN            : CONSTANT Key :=  41;
	KEY_ASTERISK              : CONSTANT Key :=  42;
	KEY_PLUS                  : CONSTANT Key :=  43;
	KEY_COMMA                 : CONSTANT Key :=  44;
	KEY_MINUS                 : CONSTANT Key :=  45;
	KEY_PERIOD                : CONSTANT Key :=  46;
	KEY_SLASH                 : CONSTANT Key :=  47;
	KEY_0                     : CONSTANT Key :=  48;
	KEY_1                     : CONSTANT Key :=  49;
	KEY_2                     : CONSTANT Key :=  50;
	KEY_3                     : CONSTANT Key :=  51;
	KEY_4                     : CONSTANT Key :=  52;
	KEY_5                     : CONSTANT Key :=  53;
	KEY_6                     : CONSTANT Key :=  54;
	KEY_7                     : CONSTANT Key :=  55;
	KEY_8                     : CONSTANT Key :=  56;
	KEY_9                     : CONSTANT Key :=  57;
	KEY_COLON                 : CONSTANT Key :=  58;
	KEY_SEMICOLON             : CONSTANT Key :=  59;
	KEY_LESS                  : CONSTANT Key :=  60;
	KEY_EQUALS                : CONSTANT Key :=  61;
	KEY_GREATER               : CONSTANT Key :=  62;
	KEY_QUESTION              : CONSTANT Key :=  63;
	KEY_AT                    : CONSTANT Key :=  64;
	KEY_LEFTBRACKET           : CONSTANT Key :=  91;
	KEY_BACKSLASH             : CONSTANT Key :=  92;
	KEY_RIGHTBRACKET          : CONSTANT Key :=  93;
	KEY_CARET                 : CONSTANT Key :=  94;
	KEY_UNDERSCORE            : CONSTANT Key :=  95;
	KEY_BACKQUOTE             : CONSTANT Key :=  96;
	KEY_a                     : CONSTANT Key :=  97;
	KEY_b                     : CONSTANT Key :=  98;
	KEY_c                     : CONSTANT Key :=  99;
	KEY_d                     : CONSTANT Key := 100;
	KEY_e                     : CONSTANT Key := 101;
	KEY_f                     : CONSTANT Key := 102;
	KEY_g                     : CONSTANT Key := 103;
	KEY_h                     : CONSTANT Key := 104;
	KEY_i                     : CONSTANT Key := 105;
	KEY_j                     : CONSTANT Key := 106;
	KEY_k                     : CONSTANT Key := 107;
	KEY_l                     : CONSTANT Key := 108;
	KEY_m                     : CONSTANT Key := 109;
	KEY_n                     : CONSTANT Key := 110;
	KEY_o                     : CONSTANT Key := 111;
	KEY_p                     : CONSTANT Key := 112;
	KEY_q                     : CONSTANT Key := 113;
	KEY_r                     : CONSTANT Key := 114;
	KEY_s                     : CONSTANT Key := 115;
	KEY_t                     : CONSTANT Key := 116;
	KEY_u                     : CONSTANT Key := 117;
	KEY_v                     : CONSTANT Key := 118;
	KEY_w                     : CONSTANT Key := 119;
	KEY_x                     : CONSTANT Key := 120;
	KEY_y                     : CONSTANT Key := 121;
	KEY_z                     : CONSTANT Key := 122;
	KEY_DELETE                : CONSTANT Key := 127;
	KEY_WORLD_0               : CONSTANT Key := 160;
	KEY_WORLD_1               : CONSTANT Key := 161;
	KEY_WORLD_2               : CONSTANT Key := 162;
	KEY_WORLD_3               : CONSTANT Key := 163;
	KEY_WORLD_4               : CONSTANT Key := 164;
	KEY_WORLD_5               : CONSTANT Key := 165;
	KEY_WORLD_6               : CONSTANT Key := 166;
	KEY_WORLD_7               : CONSTANT Key := 167;
	KEY_WORLD_8               : CONSTANT Key := 168;
	KEY_WORLD_9               : CONSTANT Key := 169;
	KEY_WORLD_10              : CONSTANT Key := 170;
	KEY_WORLD_11              : CONSTANT Key := 171;
	KEY_WORLD_12              : CONSTANT Key := 172;
	KEY_WORLD_13              : CONSTANT Key := 173;
	KEY_WORLD_14              : CONSTANT Key := 174;
	KEY_WORLD_15              : CONSTANT Key := 175;
	KEY_WORLD_16              : CONSTANT Key := 176;
	KEY_WORLD_17              : CONSTANT Key := 177;
	KEY_WORLD_18              : CONSTANT Key := 178;
	KEY_WORLD_19              : CONSTANT Key := 179;
	KEY_WORLD_20              : CONSTANT Key := 180;
	KEY_WORLD_21              : CONSTANT Key := 181;
	KEY_WORLD_22              : CONSTANT Key := 182;
	KEY_WORLD_23              : CONSTANT Key := 183;
	KEY_WORLD_24              : CONSTANT Key := 184;
	KEY_WORLD_25              : CONSTANT Key := 185;
	KEY_WORLD_26              : CONSTANT Key := 186;
	KEY_WORLD_27              : CONSTANT Key := 187;
	KEY_WORLD_28              : CONSTANT Key := 188;
	KEY_WORLD_29              : CONSTANT Key := 189;
	KEY_WORLD_30              : CONSTANT Key := 190;
	KEY_WORLD_31              : CONSTANT Key := 191;
	KEY_WORLD_32              : CONSTANT Key := 192;
	KEY_WORLD_33              : CONSTANT Key := 193;
	KEY_WORLD_34              : CONSTANT Key := 194;
	KEY_WORLD_35              : CONSTANT Key := 195;
	KEY_WORLD_36              : CONSTANT Key := 196;
	KEY_WORLD_37              : CONSTANT Key := 197;
	KEY_WORLD_38              : CONSTANT Key := 198;
	KEY_WORLD_39              : CONSTANT Key := 199;
	KEY_WORLD_40              : CONSTANT Key := 200;
	KEY_WORLD_41              : CONSTANT Key := 201;
	KEY_WORLD_42              : CONSTANT Key := 202;
	KEY_WORLD_43              : CONSTANT Key := 203;
	KEY_WORLD_44              : CONSTANT Key := 204;
	KEY_WORLD_45              : CONSTANT Key := 205;
	KEY_WORLD_46              : CONSTANT Key := 206;
	KEY_WORLD_47              : CONSTANT Key := 207;
	KEY_WORLD_48              : CONSTANT Key := 208;
	KEY_WORLD_49              : CONSTANT Key := 209;
	KEY_WORLD_50              : CONSTANT Key := 210;
	KEY_WORLD_51              : CONSTANT Key := 211;
	KEY_WORLD_52              : CONSTANT Key := 212;
	KEY_WORLD_53              : CONSTANT Key := 213;
	KEY_WORLD_54              : CONSTANT Key := 214;
	KEY_WORLD_55              : CONSTANT Key := 215;
	KEY_WORLD_56              : CONSTANT Key := 216;
	KEY_WORLD_57              : CONSTANT Key := 217;
	KEY_WORLD_58              : CONSTANT Key := 218;
	KEY_WORLD_59              : CONSTANT Key := 219;
	KEY_WORLD_60              : CONSTANT Key := 220;
	KEY_WORLD_61              : CONSTANT Key := 221;
	KEY_WORLD_62              : CONSTANT Key := 222;
	KEY_WORLD_63              : CONSTANT Key := 223;
	KEY_WORLD_64              : CONSTANT Key := 224;
	KEY_WORLD_65              : CONSTANT Key := 225;
	KEY_WORLD_66              : CONSTANT Key := 226;
	KEY_WORLD_67              : CONSTANT Key := 227;
	KEY_WORLD_68              : CONSTANT Key := 228;
	KEY_WORLD_69              : CONSTANT Key := 229;
	KEY_WORLD_70              : CONSTANT Key := 230;
	KEY_WORLD_71              : CONSTANT Key := 231;
	KEY_WORLD_72              : CONSTANT Key := 232;
	KEY_WORLD_73              : CONSTANT Key := 233;
	KEY_WORLD_74              : CONSTANT Key := 234;
	KEY_WORLD_75              : CONSTANT Key := 235;
	KEY_WORLD_76              : CONSTANT Key := 236;
	KEY_WORLD_77              : CONSTANT Key := 237;
	KEY_WORLD_78              : CONSTANT Key := 238;
	KEY_WORLD_79              : CONSTANT Key := 239;
	KEY_WORLD_80              : CONSTANT Key := 240;
	KEY_WORLD_81              : CONSTANT Key := 241;
	KEY_WORLD_82              : CONSTANT Key := 242;
	KEY_WORLD_83              : CONSTANT Key := 243;
	KEY_WORLD_84              : CONSTANT Key := 244;
	KEY_WORLD_85              : CONSTANT Key := 245;
	KEY_WORLD_86              : CONSTANT Key := 246;
	KEY_WORLD_87              : CONSTANT Key := 247;
	KEY_WORLD_88              : CONSTANT Key := 248;
	KEY_WORLD_89              : CONSTANT Key := 249;
	KEY_WORLD_90              : CONSTANT Key := 250;
	KEY_WORLD_91              : CONSTANT Key := 251;
	KEY_WORLD_92              : CONSTANT Key := 252;
	KEY_WORLD_93              : CONSTANT Key := 253;
	KEY_WORLD_94              : CONSTANT Key := 254;
	KEY_WORLD_95              : CONSTANT Key := 255;
	KEY_KP0                   : CONSTANT Key := 256;
	KEY_KP1                   : CONSTANT Key := 257;
	KEY_KP2                   : CONSTANT Key := 258;
	KEY_KP3                   : CONSTANT Key := 259;
	KEY_KP4                   : CONSTANT Key := 260;
	KEY_KP5                   : CONSTANT Key := 261;
	KEY_KP6                   : CONSTANT Key := 262;
	KEY_KP7                   : CONSTANT Key := 263;
	KEY_KP8                   : CONSTANT Key := 264;
	KEY_KP9                   : CONSTANT Key := 265;
	KEY_KP_PERIOD             : CONSTANT Key := 266;
	KEY_KP_DIVIDE             : CONSTANT Key := 267;
	KEY_KP_MULTIPLY           : CONSTANT Key := 268;
	KEY_KP_MINUS              : CONSTANT Key := 269;
	KEY_KP_PLUS               : CONSTANT Key := 270;
	KEY_KP_ENTER              : CONSTANT Key := 271;
	KEY_KP_EQUALS             : CONSTANT Key := 272;
	KEY_UP                    : CONSTANT Key := 273;
	KEY_DOWN                  : CONSTANT Key := 274;
	KEY_RIGHT                 : CONSTANT Key := 275;
	KEY_LEFT                  : CONSTANT Key := 276;
	KEY_INSERT                : CONSTANT Key := 277;
	KEY_HOME                  : CONSTANT Key := 278;
	KEY_END                   : CONSTANT Key := 279;
	KEY_PAGEUP                : CONSTANT Key := 280;
	KEY_PAGEDOWN              : CONSTANT Key := 281;
	KEY_F1                    : CONSTANT Key := 282;
	KEY_F2                    : CONSTANT Key := 283;
	KEY_F3                    : CONSTANT Key := 284;
	KEY_F4                    : CONSTANT Key := 285;
	KEY_F5                    : CONSTANT Key := 286;
	KEY_F6                    : CONSTANT Key := 287;
	KEY_F7                    : CONSTANT Key := 288;
	KEY_F8                    : CONSTANT Key := 289;
	KEY_F9                    : CONSTANT Key := 290;
	KEY_F10                   : CONSTANT Key := 291;
	KEY_F11                   : CONSTANT Key := 292;
	KEY_F12                   : CONSTANT Key := 293;
	KEY_F13                   : CONSTANT Key := 294;
	KEY_F14                   : CONSTANT Key := 295;
	KEY_F15                   : CONSTANT Key := 296;
	KEY_NUMLOCK               : CONSTANT Key := 300;
	KEY_CAPSLOCK              : CONSTANT Key := 301;
	KEY_SCROLLOCK             : CONSTANT Key := 302;
	KEY_SHIFT_RIGHT           : CONSTANT Key := 303;
	KEY_SHIFT_LEFT            : CONSTANT Key := 304;
	KEY_CTRL_RIGHT            : CONSTANT Key := 305;
	KEY_CTRL_LEFT             : CONSTANT Key := 306;
	KEY_ALT_RIGHT             : CONSTANT Key := 307;
	KEY_ALT_LEFT              : CONSTANT Key := 308;
	KEY_META_RIGHT            : CONSTANT Key := 309;
	KEY_META_LEFT             : CONSTANT Key := 310;
	KEY_SUPER_LEFT            : CONSTANT Key := 311;
	KEY_SUPER_RIGHT           : CONSTANT Key := 312;
	KEY_MODE                  : CONSTANT Key := 313;
	KEY_COMPOSE               : CONSTANT Key := 314;
	KEY_HELP                  : CONSTANT Key := 315;
	KEY_PRINT                 : CONSTANT Key := 316;
	KEY_SYSREQ                : CONSTANT Key := 317;
	KEY_BREAK                 : CONSTANT Key := 318;
	KEY_MENU                  : CONSTANT Key := 319;
	KEY_POWER                 : CONSTANT Key := 320;
	KEY_EURO                  : CONSTANT Key := 321;
	KEY_LAST                  : CONSTANT Key := 322;
	KEY_MODIFIER_NONE         : CONSTANT Key_Modifier := 16#0000#;
	KEY_MODIFIER_SHIFT_LEFT   : CONSTANT Key_Modifier := 16#0001#;
	KEY_MODIFIER_SHIFT_RIGHT  : CONSTANT Key_Modifier := 16#0002#;
	KEY_MODIFIER_CTRL_LEFT    : CONSTANT Key_Modifier := 16#0040#;
	KEY_MODIFIER_CTRL_RIGHT   : CONSTANT Key_Modifier := 16#0080#;
	KEY_MODIFIER_ALT_LEFT     : CONSTANT Key_Modifier := 16#0100#;
	KEY_MODIFIER_ALT_RIGHT    : CONSTANT Key_Modifier := 16#0200#;
	KEY_MODIFIER_META_LEFT    : CONSTANT Key_Modifier := 16#0400#;
	KEY_MODIFIER_META_RIGHT   : CONSTANT Key_Modifier := 16#0800#;
	KEY_MODIFIER_NUM          : CONSTANT Key_Modifier := 16#1000#;
	KEY_MODIFIER_CAPS         : CONSTANT Key_Modifier := 16#2000#;
	KEY_MODIFIER_MODE         : CONSTANT Key_Modifier := 16#4000#;
	KEY_MODIFIER_RESERVED     : CONSTANT Key_Modifier := 16#8000#;
	KEY_MODIFIER_CTRL         : CONSTANT Key_Modifier := (KEY_MODIFIER_CTRL_LEFT  or KEY_MODIFIER_CTRL_RIGHT);
	KEY_MODIFIER_SHIFT        : CONSTANT Key_Modifier := (KEY_MODIFIER_SHIFT_LEFT or KEY_MODIFIER_SHIFT_RIGHT);
	KEY_MODIFIER_ALT          : CONSTANT Key_Modifier := (KEY_MODIFIER_ALT_LEFT   or KEY_MODIFIER_ALT_RIGHT);
	KEY_MODIFIER_META         : CONSTANT Key_Modifier := (KEY_MODIFIER_META_LEFT  or KEY_MODIFIER_META_RIGHT);
	POSTFIX_FILE_NAME         : CONSTANT String := "Combat_Arena.Media_Layer";
	PREFIX_SEPORATOR          : CONSTANT String := "-------------------------------";
	PREFIX_LINE_NUMBER        : CONSTANT String := "Line number: ";
	PREFIX_FATAL              : CONSTANT String := "Fatal Error Encountered...";
	PREFIX_NONFATAL           : CONSTANT String := "Non-fatal Error Encountered...";
	INITIALIZATION_SDL        : CONSTANT String := "SDL was unable to load: ";
	INITIALIZATION_SURFACE    : CONSTANT String := "The video mode was unable to be set: ";
	INITIALIZATION_AUDIO      : CONSTANT String := "The audio system was unable to load: ";
	FILE_LOAD_AUDIO           : CONSTANT String := "Error loading audio file: ";
	FILE_ACCESS_AUDIO         : CONSTANT String := "Attempt at audio access without proper flags set.";
	VIDEO_MODE_REFRESH        : CONSTANT String := "The video mode was unable to be refreashed with surface: ";
	ALPHA_OPAQUE              : constant := 255;
	ALPHA_TRANSPARENT         : constant := 0;
	type Void_Ptr
		is new System.Address;
	type Integer_8_Unsigned
		is new Interfaces.C.unsigned_char;
	type Integer_8_Unsigned_Access
		is access all Integer_8_Unsigned;
		pragma Convention (C, Integer_8_Unsigned_Access);
	type Integer_8_Signed
		is new Interfaces.C.char;
	type Integer_8_Signed_Access
		is access all Integer_8_Signed;
		pragma Convention (C, Integer_8_Signed_Access);
	type Integer_16_Unsigned
		is new Interfaces.C.unsigned_short;
	type Integer_16_Unsigned_Access
		is access all Integer_16_Unsigned;
		pragma Convention (C, Integer_16_Unsigned_Access);
	type Integer_16_Signed
		is new Interfaces.C.short;
	type Integer_16_Signed_Access
		is access all Integer_16_Signed;
		pragma Convention (C, Integer_16_Signed_Access);
	type Integer_32_Unsigned
		is new Interfaces.C.unsigned;
	type Integer_32_Unsigned_Access
		is access all Integer_32_Unsigned;
		pragma Convention (C, Integer_32_Unsigned_Access);
	subtype Integer_32_Signed
		is Standard.Integer;
	type Integer_32_Signed_Access
		is access all Integer_32_Signed;
		pragma Convention (C, Integer_32_Signed_Access);
	type Integer_64_Unsigned
		is new Interfaces.C.Extensions.unsigned_long_long;
	type Integer_64_Unsigned_Access
		is access all Integer_64_Unsigned;
		pragma Convention (C, Integer_64_Unsigned_Access);
	type Integer_64_Signed
		is new Interfaces.C.Extensions.long_long;
	type Integer_64_Signed_Access
		is access all Integer_64_Signed;
		pragma Convention (C, Integer_64_Signed_Access);
	subtype Float_32
		is Standard.Float;
	type Bit_1
		is mod 2**1;
	type Bit_6
		is mod 2**6;
	type Bit_16
		is mod 2**16;
	type Bit_31
		is mod 2**31;
	type keysym
		is record
			scancode : Integer_8_Unsigned;
			sym      : Key;
			the_mod  : Key_Modifier;
			unicode  : Integer_16_Unsigned;
		end record;
	for keysym'Size
		use 8*16;
		pragma Convention (C, keysym);
	type keysym_ptr
		is access all  keysym;
		pragma Convention (C, keysym_ptr);
	type keysym_Const_ptr
		is access constant keysym;
		pragma Convention (C, keysym_Const_ptr);
	type ActiveEvent
		is record
         --  the_type,         --  ISACTIVEEVENT
			the_type : Event_Type; --  ISACTIVEEVENT;
			gain,          --  Whether given states were gained or lost (1/0)
			state    : Active_State; --  A mask of the focus states
		end record;
		pragma Convention (C, ActiveEvent);
	type KeyboardEvent
		is record
			the_type : Event_Type;
			which    : Integer_8_Unsigned;
			state    : Integer_8_Unsigned;
			keysym2  : aliased keysym;
		end record;
		pragma Convention (C, KeyboardEvent);
	type MouseMotionEvent
		is record
			the_type : Event_Type;
			which    : Integer_8_Unsigned;
			state    : Integer_8_Unsigned;
			x, y     : Integer_16_Unsigned;
			xrel     : Integer_16_Signed;
			yrel     : Integer_16_Signed;
		end record;
		pragma Convention (C, MouseMotionEvent);
	type MouseButtonEvent
		is record
			the_type : Event_Type;
			which    : Integer_8_Unsigned;
			button   : Integer_8_Unsigned;
			state    : SDL.Mouse.Mouse_Button_State;
			x, y     : Integer_16_Unsigned;
		end record;
		pragma Convention (C, MouseButtonEvent);
	type ResizeEvent
		is record
			the_type : Event_Type;
			w, h : Interfaces.C.int;
		end record;
		pragma Convention (C, ResizeEvent);   
	type QuitEvent
		is record
			the_type : Event_Type;
		end record;
		pragma Convention (C, QuitEvent);
	type UserEvent
		is record
			the_type : Event_Type; 
			code     : Interfaces.C.int;
			data1    : void_ptr;
			data2    : void_ptr; 
		end record;
		pragma Convention (C, UserEvent);
	type SysWMmsg_ptr
		is new System.Address;
	type SysWMEvent
		is record
			the_type : Event_Type;
			msg      : SysWMmsg_ptr;
		end record;
		pragma Convention (C, SysWMEvent);
	type Event_Selection
		is (
			Is_Event_Type,
			Is_ActiveEvent,
			Is_KeyboardEvent,
			Is_MouseMotionEvent,
			Is_MouseButtonEvent,
			Is_ResizeEvent,
			Is_QuitEvent,
			Is_UserEvent,
			Is_SysWMEvent
		);
	type Event
		(Event_Selec : Event_Selection := Is_Event_Type)
		is record
			case Event_Selec is
				when Is_Event_Type       => the_type : Event_Type;
				when Is_ActiveEvent      => active   : ActiveEvent;
				when Is_KeyboardEvent    => key      : KeyboardEvent;
				when Is_MouseMotionEvent => motion   : MouseMotionEvent;
				when Is_MouseButtonEvent => button   : MouseButtonEvent;
				when Is_ResizeEvent      => resize   : ResizeEvent;
				when Is_QuitEvent        => quit     : QuitEvent;
				when Is_UserEvent        => user     : UserEvent;
				when Is_SysWMEvent       => syswm    : SysWMEvent;
			end case;
		end record;
		pragma Convention (C, Event);
		pragma Unchecked_Union (Event);
		type Event_ptr is access all Event;
   pragma Convention (C, Event_ptr);
	type Rectange is
		record
			x, y : Integer_16_Signed;
			w, h : Integer_16_Unsigned;
		end record;
		pragma Convention (C, Rectange);
	type Rectange_Access
		is access all Rectange;
		pragma Convention (C, Rectange_Access);
	type Rectange_Access_Access
		is access all Rectange_Access;
		pragma Convention (C, Rectange_Access_Access);
	type Rectanges_Array
		is array (Interfaces.C.unsigned range <>)
		of aliased Rectange;
	type Rectanges_Array_Access
		is access all Rectanges_Array;
	type Color is
		record
			r      : Integer_8_Unsigned;
			g      : Integer_8_Unsigned;
			b      : Integer_8_Unsigned;
			unused : Integer_8_Unsigned;
		end record;
		pragma Convention (C, Color);
	type Color_Access
		is access all Color;
		pragma Convention (C, Color_Access);
	Null_Color : Color := (0, 0, 0, 123);
	type Colors_Array is
		array (Interfaces.C.size_t range <>)
		of aliased Color;
	package Color_AccessOps
		is new Interfaces.C.Pointers
		(
			Index              => Interfaces.C.size_t,
			Element            => Color,
			Element_Array      => Colors_Array,
			Default_Terminator => Null_Color
		);
	type Palette
		is record
			ncolors : Interfaces.C.int;
			colors  : Color_Access;
		end record;
		pragma Convention (C, Palette);
	type Palette_Access 
		is access Palette;
		pragma Convention (C, Palette_Access);
	type PixelFormat
		is record
			palette       : Palette_Access;
			BitsPerPixel  : Integer_8_Unsigned;
			BytesPerPixel : Integer_8_Unsigned;
			Rloss         : Integer_8_Unsigned;
			Gloss         : Integer_8_Unsigned;
			Bloss         : Integer_8_Unsigned;
			Aloss         : Integer_8_Unsigned;
			Rshift        : Integer_8_Unsigned;
			Gshift        : Integer_8_Unsigned;
			Bshift        : Integer_8_Unsigned;
			Ashift        : Integer_8_Unsigned;
			Rmask         : Integer_32_Unsigned;
			Gmask         : Integer_32_Unsigned;
			Bmask         : Integer_32_Unsigned;
			Amask         : Integer_32_Unsigned;
			colorkey      : Integer_32_Unsigned;
			alpha         : Integer_8_Unsigned;
		end record;
		pragma Convention (C, PixelFormat);
	type PixelFormat_Access
		is access constant PixelFormat;
		pragma Convention (C, PixelFormat_Access);
	type private_hwdata_Access
		is new System.Address;
	type BlitMap_Access
		is new System.Address; 
	type Surface
		is record
			flags          : Surface_Flags;
			format         : PixelFormat_Access;
			w, h           : Interfaces.C.int;
			pitch          : Integer_16_Unsigned;
			offset         : Interfaces.C.int;
			hwdata         : private_hwdata_Access;
			clip_Rectange  : Rectange;
			unused1        : Integer_32_Unsigned;
			locked         : Integer_32_Unsigned;
			map            : BlitMap_Access;
			format_version : Interfaces.C.unsigned;
			refcount       : Interfaces.C.int;
		end record;
		pragma Convention (C, Surface);
	type Surface_Access
		is access all Surface;
		pragma Convention (C, Surface_Access);
	type VideoInfo
		is record
			hw_available : Bit_1;
			wm_available : Bit_1;
			UnusedBit_1  : Bit_6;
			UnusedBits2  : Bit_1;
			blit_hw      : Bit_1;
			blit_hw_CC   : Bit_1;
			blit_hw_A    : Bit_1;
			blit_sw      : Bit_1;
			blit_sw_CC   : Bit_1;
			blit_sw_A    : Bit_1;
			blit_fill    : Bit_1;
			UnusedBits3  : Bit_16;
			video_mem    : Integer_32_Unsigned;
			vfmt         : PixelFormat_Access;
		end record;
	for VideoInfo
		use record
			hw_available at 0 range 0 .. 0;
			wm_available at 0 range 1 .. 1;
			UnusedBit_1  at 0 range 2 .. 7;
			UnusedBits2  at 1 range 0 .. 0;
			blit_hw      at 1 range 1 .. 1;
			blit_hw_CC   at 1 range 2 .. 2;
			blit_hw_A    at 1 range 3 .. 3;
			blit_sw      at 1 range 4 .. 4;
			blit_sw_CC   at 1 range 5 .. 5;
			blit_sw_A    at 1 range 6 .. 6;
			blit_fill    at 1 range 7 .. 7;
			UnusedBits3  at 2 range 0 .. 15;
			video_mem    at 4 range 0 .. 31;
			vfmt         at 8 range 0 .. 31;
		end record;
		pragma Convention (C, VideoInfo);
	type VideoInfo_Access
		is access all VideoInfo;
		pragma Convention (C, VideoInfo_Access);
	type VideoInfo_ConstPtr
		is access constant VideoInfo;
		pragma Convention (C, VideoInfo_ConstPtr);
	type Chunk
		is record
			allocated : Interfaces.C.int;
			abuf      : Integer_8_Unsigned_Access;
			alen      : Integer_32_Unsigned;
			volume    : Integer_8_Unsigned;  --  Per-sample volume, 0-128
		end record;
		pragma Convention (C, Chunk);
	type Chunk_ptr
		is access Chunk;
		pragma Convention (C, Chunk_ptr);
   null_Chunk_ptr : constant Chunk_ptr := null;
	type Attribute_Setting_Handle
		is record
			Attribute : GLattr;
			Value     : Short_Integer;
		end record;
	type Audio_Handle
		is record
			File_Name : Unbounded_String;
			Data      : Chunk_ptr;
		end record;
	type Audio_Handle_Array
		is array (1..MAX_SOUNDS)
		of Audio_Handle;
	type Audio_Initialization_Handle
		is record
			Frequency : Integer;
			Format    : Format_Flag;
			Channels  : Integer;
			Data_Size : Integer;
		end record;
	type Video_Initialization_Handle
		is record
			Width              : Short_Integer;
			Height             : Short_Integer;
			Max_Frame_Rate     : Short_Integer;
			Bits_Per_Pixel     : Short_Integer;
			Flag_FullScreen    : Boolean;
			Flag_Audio         : Boolean;
			Flag_OpenGL        : Boolean;
			Flag_Double_Buffer : Boolean;
			Title              : Unbounded_String;
			Icon_File          : Unbounded_String;
			Surface            : Surface_Access;
		end record;
	DEFAULT_AUDIO_ARRAY :
		Audio_Handle_Array :=
		(
			others =>
			(
				File_Name => To_Unbounded_String(""),
				Data      => Null
			)
		);
	DEFAULT_AUDIO_SETTINGS :
		Audio_Initialization_Handle :=
		(
			Frequency => 22050,
			Format    => AUDIO_S16,
			Channels  => 2,
			Data_Size => 4096
		);
	DEFAULT_VIDEO_SETTINGS :
		Video_Initialization_Handle :=
		(
			Width              => DEFAULT_RESOLUTION_WIDTH,
			Height             => DEFAULT_RESOLUTION_HEIGHT,
			Max_Frame_Rate     => DEFAULT_FRAME_RATE,
			Bits_Per_Pixel     => DEFAULT_BITS_PER_PIXEL,
			Flag_FullScreen    => FALSE,
			Flag_Audio         => FALSE,
			Flag_OpenGL        => TRUE,
			Flag_Double_Buffer => TRUE,
			Title              => To_Unbounded_String("DEFAULT"),
			Icon_File          => To_Unbounded_String(""),
			Surface            => Null
		);
	ATTRIBUTES_OPENGL : array (1..5) of
		Attribute_Setting_Handle :=
		(
			(GL_RED_SIZE    ,5),
			(GL_GREEN_SIZE  ,5),
			(GL_BLUE_SIZE   ,5),
			(GL_DEPTH_SIZE  ,32),
			(GL_DOUBLEBUFFER,1)
		);
	procedure Initialize_Audio
		(Audio_Array     : in out Audio_Handle_Array;
		 Audio_Prefences : in out Audio_Initialization_Handle);
	procedure Finalize_Audio
		(Audio_Array : in out Audio_Handle_Array);
	procedure Initialize_Video
		(Video : in out Video_Initialization_Handle);
	procedure Finalize_Video
		(Video : in out Video_Initialization_Handle);
	procedure PollEventVP
		(result    :    out Interfaces.C.int;
		 the_event : in out Event);
	function OpenAudio
		(frequency : Interfaces.C.int;
		 format    : Format_Flag;
		 channels  : Interfaces.C.int;
		 chunksize : Interfaces.C.int)
		return C.int;
		pragma Import (C, OpenAudio, "Mix_OpenAudio");
	function Load_WAV
		(file : String)
		return Chunk_ptr;
		pragma Inline (Load_WAV);
	function Set_Video_Mode 
		(width  : Interfaces.C.int;
		 height : Interfaces.C.int;
		 bpp    : Interfaces.C.int;
		 flags  : Surface_Flags)
		return Surface_Access;
	function Get_Video_Info
		return VideoInfo_ConstPtr;
	procedure Quit_Framework;
	function Get_Error
		return String;
		pragma Inline (Get_Error);
	procedure Set_Video_Caption
		(title : in String;
		 icon  : in String);
		pragma Inline (Set_Video_Caption);
	function Get_Ticks
		return Integer_32_Unsigned;
	function GL_LoadLibrary
		(path : Interfaces.C.Strings.chars_ptr)
		return Interfaces.C.int;
	procedure GL_GetProcAddress
		(proc : Interfaces.C.Strings.chars_ptr);
	function GL_SetAttribute
		(attr  : GLattr;
		 value : Interfaces.C.int)
		return Interfaces.C.int;   
	procedure GL_SetAttribute
		(attr  : GLattr;
		 value : Interfaces.C.int);
		pragma Import (C, GL_SetAttribute, "SDL_GL_SetAttribute");
	function GL_GetAttribute
		(attr  : GLattr;
		 value : access Interfaces.C.int)
		return Interfaces.C.int;
	procedure GL_GetAttribute
		(attr  : GLattr;
		 value : access Interfaces.C.int);
	procedure GL_GetAttribute
		(attr  : GLattr;
		 value : out Interfaces.C.int);
	procedure GL_SwapBuffers;
	procedure GL_UpdateRectanges
		(numRectanges : Interfaces.C.int;
		 Rectanges    : Rectange_Access);
	procedure GL_Lock;
	procedure GL_Unlock;
   procedure FreeChunk (chunk : Chunk_ptr);
   procedure CloseAudio;
   function Initialize_Framework (flags :  Initialization_Flag) return Interfaces.C.int;
private
	pragma Import (C, Initialize_Framework, "SDL_Init");
	pragma Import (C, CloseAudio, "Mix_CloseAudio");
	pragma Import (C, FreeChunk, "Mix_FreeChunk");
	pragma Import (C, Get_Ticks, "SDL_GetTicks");
	pragma Import (C, PollEventVP, "SDL_PollEvent");
	pragma Import_Valued_Procedure (PollEventVP);
	pragma Import (C, Set_Video_Mode, "SDL_SetVideoMode");
	pragma Import (C, GL_GetProcAddress, "SDL_GL_GetProcAddress");
	pragma Import (C, Get_Video_Info, "SDL_GetVideoInfo");
	pragma Import (C, GL_LoadLibrary, "SDL_GL_LoadLibrary");
	pragma Import (C, GL_GetAttribute, "SDL_GL_GetAttribute");
	pragma Import (C, GL_SwapBuffers, "SDL_GL_SwapBuffers");
	pragma Import (C, GL_UpdateRectanges, "SDL_UpdateRectanges");
	pragma Import (C, GL_Lock, "SDL_GL_Lock");
	pragma Import (C, GL_Unlock, "SDL_GL_Unlock");
	pragma Import (C, Quit_Framework, "SDL_Quit");
end Game_Framework;
