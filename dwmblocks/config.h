/*
 * The status bar, as blocks of shell output.
 *
 * Order runs left to right and follows the right-hand side of the awesome
 * wibar, with the graphs that live on its left edge folded in at the start.
 * dwm draws the status text in one run at the right of the bar, so there is no
 * left-hand section to put them in.
 *
 * The signal number is what a click sends. It has to be non-zero for a block
 * to be clickable at all: dwmblocks prefixes the block's output with that byte
 * and the statuscmd patch reads it back to work out which block was hit.
 * Signal a block by hand with `pkill -RTMIN+<n> dwmblocks`.
 *
 * Interval 0 means the block only updates on its signal.
 */
static const Block blocks[] = {
	/*Icon*/  /*Command*/                 /*Interval*/  /*Signal*/
	{"",      "dwm-cpu",                  2,            7},
	{"",      "dwm-mem",                  5,            8},
	{"",      "dwm-temp",                 7,            9},
	{"",      "dwm-pomodoro",             1,            1},
	{"",      "dwm-caffeine",             0,            3},
	{"",      "dwm-mpris",                3,            4},
	{"",      "dwm-volume",               10,           2},
	{"",      "dwm-battery",              61,           5},
	{"",      "dwm-weather",              900,          6},
	{"",      "dwm-clock",                30,           10},
};

/* Two spaces, because the scripts already colour their own labels and a pipe
 * between every block reads as busier than the awesome bar does. */
static char *delim = "  ";
