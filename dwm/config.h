/* See LICENSE file for copyright and license details. */

/*
 * dwm configuration, translated from the awesome config in ../awesome.
 *
 * Bindings keep awesome's key assignments wherever dwm has an equivalent, so
 * the muscle memory carries over. Where it has none the binding is left out
 * and listed under "Divergences" in ../dwm/README.md, rather than silently
 * rebound to something else.
 */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 1;

/* Inset applied to every side of every tiled client, so the space between two
 * of them is twice this and the space at a screen edge is one of it. That is
 * the same model as awesome's useless_gap, which theme.lua sets to dpi(5): 8
 * pixels at the 144 DPI xinitrc.dwm pins. dwm has no DPI-aware config, so this
 * is the pixel count rather than a scaled value, and a machine running at a
 * different DPI wants a different number here. */
static const unsigned int gappx     = 8;

static const unsigned int snap      = 32;
static const unsigned int systraypinning = 0;   /* 0: systray follows the selected monitor */
static const unsigned int systrayonleft  = 0;
static const unsigned int systrayspacing = 2;
static const int systraypinningfailfirst = 1;
static const int showsystray        = 1;
static const int showbar            = 1;
static const int topbar             = 1;

/* Point size, as in awesome's settings.font. Both read Xft.dpi, which
 * xinit/xinitrc.dwm pins to 144 for the same reason config/settings.lua does:
 * the X server's EDID guess changes between reboots. */
static const char *fonts[]          = { "Hack Nerd Font:size=8" };
static const char dmenufont[]       = "Hack Nerd Font:size=8";

/* SchemeNorm and SchemeSel, generated from the pywal palette at build time. */
#include "colors.h"

/* tagging */
static const char *tags[] = { "1", "2", "3", "4" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class              instance   title            tags  isfloating  monitor */
	{ "Arandr",           NULL,      NULL,            0,    1,          -1 },
	{ "Blueman-manager",  NULL,      NULL,            0,    1,          -1 },
	{ "Gpick",            NULL,      NULL,            0,    1,          -1 },
	{ "Kruler",           NULL,      NULL,            0,    1,          -1 },
	{ "MessageWin",       NULL,      NULL,            0,    1,          -1 },
	{ "Sxiv",             NULL,      NULL,            0,    1,          -1 },
	{ "Nsxiv",            NULL,      NULL,            0,    1,          -1 },
	{ "Tor Browser",      NULL,      NULL,            0,    1,          -1 },
	{ "Wpa_gui",          NULL,      NULL,            0,    1,          -1 },
	{ "veromix",          NULL,      NULL,            0,    1,          -1 },
	{ "xtightvncviewer",  NULL,      NULL,            0,    1,          -1 },
	{ NULL,               "DTA",     NULL,            0,    1,          -1 },
	{ NULL,               "copyq",   NULL,            0,    1,          -1 },
	{ NULL,               "pinentry", NULL,           0,    1,          -1 },
	{ NULL,               NULL,      "Event Tester",  0,    1,          -1 },
};

/* layout(s) */
static const float mfact     = 0.55;
static const int nmaster     = 1;
static const int resizehints = 1;
static const int lockfullscreen = 1;

/* gaplessgrid ships as its own file, and has no forward declaration in dwm.c,
 * so it is defined before layouts[] names it. */
#include "gaplessgrid.c"

/* The order Mod+space cycles through, following config/layouts.lua as far as
 * dwm has equivalents. tile is first, so it is the default on a fresh tag. */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },           /* awful.layout.suit.tile */
	{ "|M|",      centeredmaster }, /* lain.layout.centerwork */
	{ "###",      gaplessgrid },    /* awful.layout.suit.fair */
	{ "[M]",      monocle },        /* awful.layout.suit.max */
	{ "><>",      NULL },           /* awful.layout.suit.floating */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* The status program getstatusbarpid() signals for a click on a status
 * block. It has to match the name dwmblocks installs under. */
#define STATUSBAR "dwmblocks"

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "rofi", "-show", "drun", NULL };
/* kitty's single-instance socket is per user, not per display, so a terminal
 * opened from a nested test session lands in the real session's kitty instead.
 * Grouping by DISPLAY keeps each session's terminals to itself and leaves
 * single-instance behaving as before in a real session. Through sh, because
 * the group name has to be expanded. */
#define TERMCMD SHCMD("kitty --single-instance --instance-group \"$DISPLAY\"")
static const char *runcmd[]   = { "rofi", "-show", "run", NULL };
static const char *shotcmd[]  = { "flameshot", "gui", NULL };
static const char *lockcmd[]  = { "xset", "s", "activate", NULL };

/* The bin/ scripts, shared with the polybar variant. */
static const char *wallpapercmd[] = { "dwm-wallpaper", NULL };
static const char *caffeinecmd[]  = { "dwm-caffeine", "toggle", NULL };
static const char *redshiftcmd[]  = { "dwm-redshift", "toggle", NULL };
static const char *displaycmd[]   = { "dwm-display-fix", NULL };
static const char *pomocmd[]      = { "dwm-pomodoro", "toggle-visible", NULL };

#include "helpers.c"
#include "movestack.c"

static const Key keys[] = {
	/* modifier                     key            function        argument */

	/* tags */
	{ MODKEY,                       XK_Left,       shiftview,      {.i = -1 } },
	{ MODKEY,                       XK_Right,      shiftview,      {.i = +1 } },
	{ MODKEY,                       XK_Escape,     view,           {0} },
	{ MODKEY,                       XK_Tab,        view,           {0} },
	TAGKEYS(                        XK_1,                          0)
	TAGKEYS(                        XK_2,                          1)
	TAGKEYS(                        XK_3,                          2)
	TAGKEYS(                        XK_4,                          3)

	/* launcher */
	{ MODKEY,                       XK_Return,     spawn,          TERMCMD },
	{ MODKEY,                       XK_p,          spawn,          {.v = dmenucmd } },
	{ MODKEY|ControlMask,           XK_r,          spawn,          {.v = runcmd } },
	{ MODKEY|ShiftMask,             XK_s,          spawn,          {.v = shotcmd } },

	/* personal hotkeys */
	{ MODKEY,                       XK_d,          spawn,          {.v = displaycmd } },
	{ MODKEY,                       XK_w,          spawn,          {.v = wallpapercmd } },
	{ MODKEY,                       XK_c,          spawn,          {.v = caffeinecmd } },
	{ MODKEY,                       XK_e,          spawn,          {.v = redshiftcmd } },
	{ MODKEY|ShiftMask,             XK_p,          spawn,          {.v = pomocmd } },
	{ MODKEY,                       XK_apostrophe, spawn,          {.v = lockcmd } },

	/* client focus */
	{ MODKEY,                       XK_j,          focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_k,          focusstack,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_j,          movestack,      {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_k,          movestack,      {.i = +1 } },
	{ MODKEY|Mod1Mask,              XK_j,          focusmon,       {.i = +1 } },
	{ MODKEY|Mod1Mask,              XK_k,          focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_u,          focusurgent,    {0} },

	/* layout */
	{ MODKEY,                       XK_l,          setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_h,          setmfact,       {.f = -0.05} },
	{ MODKEY|ShiftMask,             XK_h,          incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_l,          incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_space,      cyclelayout,    {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_space,      cyclelayout,    {.i = -1 } },
	{ MODKEY,                       XK_b,          togglebar,      {0} },

	/* client */
	{ MODKEY,                       XK_f,          togglefullscr,  {0} },
	{ MODKEY,                       XK_m,          setlayout,      {.v = &layouts[3]} },
	{ MODKEY|ShiftMask,             XK_c,          killclient,     {0} },
	{ MODKEY|ControlMask,           XK_space,      togglefloating, {0} },
	{ MODKEY|ControlMask,           XK_Return,     zoom,           {0} },
	{ MODKEY,                       XK_o,          tagmon,         {.i = +1 } },

	/* media */
	{ 0, XF86XK_AudioRaiseVolume, spawn, SHCMD("pactl set-sink-volume @DEFAULT_SINK@ +2%; pkill -RTMIN+2 dwmblocks") },
	{ 0, XF86XK_AudioLowerVolume, spawn, SHCMD("pactl set-sink-volume @DEFAULT_SINK@ -2%; pkill -RTMIN+2 dwmblocks") },
	{ 0, XF86XK_AudioMute, spawn, SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+2 dwmblocks") },
	{ 0, XF86XK_AudioPlay, spawn, SHCMD("playerctl play-pause") },
	{ 0, XF86XK_AudioNext, spawn, SHCMD("playerctl next") },
	{ 0, XF86XK_AudioPrev, spawn, SHCMD("playerctl previous") },
	{ 0, XF86XK_MonBrightnessUp, spawn, SHCMD("dwm-brightness up") },
	{ 0, XF86XK_MonBrightnessDown, spawn, SHCMD("dwm-brightness down") },

	/* session */
	{ MODKEY|ShiftMask,             XK_q,          quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        cyclelayout,    {.i = +1} },
	{ ClkLtSymbol,          0,              Button3,        cyclelayout,    {.i = -1} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
	{ ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
	{ ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
