/*
 * Small dispatch functions the awesome bindings need and dwm has no built-in
 * for. Included from config.h after tags[] and layouts[] are defined, because
 * all three read them.
 */

/* Move the view to the next or previous tag, wrapping at either end. Bound to
 * Mod+Left and Mod+Right, matching awful.tag.viewnext and viewprev. */
void
shiftview(const Arg *arg)
{
	Arg shifted;
	unsigned int cur = selmon->tagset[selmon->seltags] & TAGMASK;
	unsigned int n = LENGTH(tags);

	if (arg->i > 0)
		shifted.ui = (cur << arg->i) | (cur >> (n - arg->i));
	else
		shifted.ui = (cur >> -arg->i) | (cur << (n + arg->i));

	shifted.ui &= TAGMASK;
	if (shifted.ui)
		view(&shifted);
}

/* Select the first client flagged urgent, switching to its tag. Bound to
 * Mod+u, matching awful.client.urgent.jumpto. */
void
focusurgent(const Arg *arg)
{
	Client *c;
	unsigned int i;

	for (c = selmon->clients; c && !c->isurgent; c = c->next)
		;
	if (!c)
		return;

	for (i = 0; i < LENGTH(tags) && !(c->tags & (1 << i)); i++)
		;
	if (i == LENGTH(tags))
		return;

	view(&((Arg) { .ui = 1 << i }));
	focus(c);
}

/* Fullscreen the selected client. dwm only exposes setfullscreen, which takes
 * a Client and so cannot be named in keys[]. Bound to Mod+f. */
void
togglefullscr(const Arg *arg)
{
	if (selmon->sel)
		setfullscreen(selmon->sel, !selmon->sel->isfullscreen);
}

/* Step through layouts[] in order. dwm's own setlayout with a NULL argument
 * toggles between two, where Mod+space in awesome cycles the whole list. */
void
cyclelayout(const Arg *arg)
{
	unsigned int i, n = LENGTH(layouts);

	for (i = 0; i < n && &layouts[i] != selmon->lt[selmon->sellt]; i++)
		;
	if (i == n)
		i = 0;

	i = (i + n + arg->i) % n;
	setlayout(&((Arg) { .v = &layouts[i] }));
}
