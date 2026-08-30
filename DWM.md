# dwm prototype

A working port of the awesome config to dwm, in two variants: one where dwm's
own bar is the whole status bar, and one where polybar is. Everything here is
new, and nothing under `awesome/` was touched.

Both variants run. The screenshots in `screenshots/` come from
`xinit/xephyr-test.sh`, at the same 1920x1080 and 144 DPI the laptop uses.

## Layout

| Path                   | What it is                                       |
| ---------------------- | ------------------------------------------------ |
| `dwm/build.sh`         | Fetches dwm 6.5, applies `patches/`, compiles    |
| `dwm/patches/`         | Seven patches, applied in filename order         |
| `dwm/config.h`         | Keys, rules, layouts, translated from awesome    |
| `dwm/helpers.c`        | Four dispatch functions dwm has no built-in for  |
| `dwm/gen-colors.sh`    | Writes `colors.h` from the pywal palette         |
| `bin/`                 | The status scripts, shared by both variants      |
| `dwmblocks/`           | Block list and build for the no-polybar variant  |
| `polybar/config.ini`   | The polybar variant                              |
| `xinit/xinitrc.dwm`    | Session startup, ported from `autostart.lua`     |
| `xinit/xephyr-run.sh`  | Opens a nested session you can type into         |
| `xinit/xephyr-test.sh` | Runs a variant nested and screenshots it         |
| `xinit/session-lib.sh` | Nested-session setup, shared by those two        |
| `xinit/bench.sh`       | Measures memory and CPU for both variants        |

## Trying it

```sh
dwm/build.sh          # installs ~/.local/bin/dwm
dwmblocks/build.sh    # installs ~/.local/bin/dwmblocks

DOTFILES=$PWD xinit/xephyr-run.sh              # a session you can type into
DOTFILES=$PWD xinit/xephyr-test.sh dwmblocks   # screenshots instead
```

Neither build needs root. `xinit/xinitrc.dwm` is the real session entry point,
and `DWM_BAR` selects the bar.

`xephyr-run.sh` takes the same variant argument and an optional window size,
and prints the keybindings on the way up. It is safe to run from inside the
awesome session, with two things to know.

**Press Ctrl+Shift with the pointer over the window.** That is Xephyr's grab
toggle. Without it awesome answers Super itself and dwm never sees it. Xephyr
reports the current state in its title bar, and Ctrl+Shift again releases.

**Autostart is skipped.** Several of its entries `pkill` a program by name, and
`pkill` is not scoped to a display, so from in here they would kill the copy
belonging to the real session. That means no tray applets, no `xss-lock` and no
picom in the nested window. `Super+Shift+s` is the other one to leave alone: it
asks the flameshot daemon for a capture, and that daemon belongs to the real
session.

The session ends on `Super+Shift+q`, or when the window is closed.

## The compositor

picom runs in both nested sessions and in a real one, off the same
`picom/picom.conf` the awesome session uses. `DWM_NO_PICOM=1` skips it.

The nested sessions pass `--backend xrender`, where the config asks for glx and
a real session gets it. Inside Xephyr the glx backend composites one frame and
then never repaints: measured over 25 seconds, a glx session changed 0 pixels
while an xrender one changed 480 and an uncomposited one 412. A frozen
composite is what "picom isn't doing anything" looks like from the outside, and
it takes the bar's clock and every window's contents down with it. Everything
in the config survives the swap except `dual_kawase` blur, which xrender cannot
do, so the nested preview has rounded corners, fading and dimming but no blur.

The config needed two additions for dwm. dwm sets no `_NET_WM_WINDOW_TYPE` on
its bar, so the existing rule that squares off anything which is not a normal
window never matched it, and the bar came out with rounded corners. The systray
patch does give the bar `WM_CLASS = dwm`, which is matchable. dwm's systray is
a second override-redirect window beside the bar with no class of its own, so
that one is matched on being override-redirect at `y = 0`. polybar is excluded
by class for the same reason. All four additions are inert under awesome.

## The patch stack

dwm ships no layouts beyond tile, monocle and floating, and no colour in the
status text. Seven patches cover the gap.

| Patch               | Why                                                |
| ------------------- | -------------------------------------------------- |
| `status2d-systray`  | Colour in the status text, and a systray            |
| `statuscmd`         | Makes status blocks clickable                       |
| `pertag`            | Per-tag layout and master width, as awesome has     |
| `centeredmaster`    | Stands in for `lain.layout.centerwork`              |
| `gaplessgrid`       | Stands in for `awful.layout.suit.fair`              |
| `hidevacant`        | Hides empty tags, as the awesome taglist does       |
| `movestack`         | Mod+Shift+j/k, which dwm has no equivalent for      |

`02-statuscmd.diff` is regenerated against this stack rather than taken from
upstream: the published patch targets a different status2d variant and three of
its hunks conflict.

## What the two variants actually cost

Measured with `xinit/bench.sh`, 90 seconds per variant, in a nested server at
1920x1080. CPU is read from a systemd scope so that the status scripts count:
dwmblocks reaps its children through a signalfd, so their CPU never reaches its
own `cutime` and reading `/proc` alone undercounts it roughly fortyfold.

| Session          | Resident memory | CPU            |
| ---------------- | --------------- | -------------- |
| dwm + dwmblocks  | 14.4 MB         | 5.4% of a core |
| dwm + polybar    | 36.9 MB         | 5.0% of a core |
| awesome, running | 111.4 MB        | not measured   |

The CPU numbers being equal is the result worth keeping. Nearly all of it is
the status scripts, which both bars run:

| Script         | ms per run | Poll | ms/min |
| -------------- | ---------- | ---- | ------ |
| `dwm-pomodoro` | 15.9       | 1s   | 951    |
| `dwm-cpu`      | 9.7        | 2s   | 291    |
| `dwm-mpris`    | 13.7       | 3s   | 275    |
| `dwm-mem`      | 21.7       | 5s   | 261    |
| `dwm-temp`     | 14.4       | 7s   | 123    |
| `dwm-volume`   | 19.3       | 10s  | 116    |
| everything else|            |      | 35     |

2.05 seconds of CPU per minute, 3.4% of a core, before either bar draws
anything. A shell script costs 10 to 22 ms per run almost entirely in fork,
exec and bash start-up. The work each one does is trivial.

So the honest summary is that polybar costs 22 MB more resident memory and no
extra CPU, and that the pomodoro block alone is 46% of the script cost. Moving
it from a 1-second to a 5-second poll saves more CPU than dropping polybar
does.

This is also the real difference from awesome, which runs the same widgets as
in-process Lua callbacks for almost no CPU, and pays 111 MB for the privilege.
The choice is memory against CPU, not "lightweight" against "heavy".

## Two things dwm cannot do with an external bar

Both are structural, and both are worth knowing before choosing polybar.

**polybar cannot read dwm's tags.** dwm sets no `_NET_CURRENT_DESKTOP`, so
`xworkspaces` stays empty and there is no supported way to ask dwm which tags
are occupied. Getting tags into polybar needs the dwm-ipc patch and a matching
polybar fork. This config leaves dwm's own bar on for the tags, the layout
symbol and the systray, and puts polybar along the bottom.

**dwm ignores `_NET_WM_STRUT`.** Without `override-redirect = true`, dwm
manages polybar as an ordinary client and tiles it. With it, dwm leaves polybar
alone but still lays windows out over the full screen, so the bottom 27 pixels
of the lowest window sit behind the bar. Reserving that space needs a patch.

The practical consequence is that the polybar variant runs two bars, and only
one of them is optional.

## Divergences from the awesome config

Dropped, as agreed: titlebars, solo mode, the Mod+s hotkey popup, the Mod+x Lua
prompt, live theme reload, and per-screen widget instances.

Also gone, because dwm has no equivalent:

| awesome binding      | Was                            |
| -------------------- | ------------------------------ |
| `Mod+n`              | minimize (dwm has no iconify)  |
| `Mod+t`, `Mod+Shift+t` | keep on top, keep on bottom  |
| `Mod+Ctrl+m`, `Mod+Shift+m` | maximize one axis       |
| `Mod+Ctrl+h/l`       | column count                   |
| `Mod+r`              | restart in place               |
| `Mod+a`              | the desktop right-click menu   |

Changed rather than dropped:

- `Mod+m` selects the monocle layout, standing in for maximize.
- `Mod+Tab` and `Mod+Escape` both return to the last tag. awesome had
  `Mod+Tab` walking the client focus history, which dwm does not keep.
- Four tags, matching `ui/bar.lua`, so `Mod+5` through `Mod+9` do nothing.
- `Mod+Return` runs `kitty --single-instance --instance-group "$DISPLAY"`,
  where `apps.lua` passes only `--single-instance`. That socket is per user
  rather than per display, so without the group a terminal opened in a nested
  test session appears in the real session's kitty instead.
- `awful.layout.suit.tile.left` and `fair.horizontal` have no dwm layout.
- The wallpaper popout rule is gone: it relies on `below`, `sticky` and
  `skip_taskbar`, none of which dwm has.

The bar is text, so the CPU and RAM graphs became one-character bar glyphs and
the widgets that had tooltips or popups lost them. The clock keeps its calendar
by sending a notification on click.

Every glyph now comes from Hack Nerd Font, where the awesome weather widget
uses emoji. awesome renders through Pango, which falls back to Noto Color
Emoji; dwm renders through Xft, which aborts on a BGRA colour glyph unless it
is built against a patched libXft.

## One bug this turned up in the awesome config

`awesome/widgets/weather.lua` calls `api.weather.gov` without `--location`.
That endpoint answers any coordinate with more than four decimal places with a
301 redirect, and `ipapi.co` returns five. The forecast URL lookup returns
`null` and the widget shows `--°F`. `bin/dwm-weather` passes `--location`.

## Still missing

- No gaps. `useless_gap` has no equivalent without another patch.
- No transparency. The bar and titlebar alpha in `theme/alpha.lua` needs the
  dwm alpha patch and an ARGB visual.
- `dwm-display-fix` falls back to autorandr, where the awesome binding runs a
  per-machine command from the gitignored `config/machine.lua`.
