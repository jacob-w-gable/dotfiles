-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local settings = require("settings")

local themes_path = require("gears.filesystem").get_themes_dir()
local config_path = require("gears.filesystem").get_configuration_dir()
local dpi = require("beautiful.xresources").apply_dpi

-- {{{ Main
local theme = {}
theme.wallpaper = config_path .. settings.wallpaper
-- }}}

-- {{{ Styles
theme.font = "sans 8"

-- {{{ Colors
theme.fg_normal = settings.secondary_color
theme.fg_focus = settings.primary_color
theme.fg_urgent = settings.secondary_color
theme.bg_normal = settings.background_color
theme.bg_focus = settings.highlight_color
theme.bg_urgent = settings.secondary_background_color
theme.bg_systray = theme.bg_normal
theme.prompt_bg = "#00000000" -- Transparent
-- }}}

-- {{{ Borders
theme.useless_gap = dpi(3)
theme.border_width = dpi(1)
theme.border_normal = settings.background_color
theme.border_focus = settings.highlight_color
theme.border_marked = settings.highlight_color
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus = settings.secondary_background_color
if settings.opacity then
	theme.titlebar_bg_focus = theme.titlebar_bg_focus .. "D9"
end
theme.titlebar_bg_normal = settings.background_color
if settings.opacity then
	theme.titlebar_bg_normal = theme.titlebar_bg_normal .. "D9"
end
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)
-- }}}

-- {{{ Icons
-- {{{ Taglist
-- theme.taglist_squares_sel = themes_path .. "zenburn/taglist/squarefz.png"
-- theme.taglist_squares_unsel = themes_path .. "zenburn/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon = themes_path .. "zenburn/awesome-icon.png"
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
-- }}}

-- {{{ Layout
-- Theses are sourced from the multicolor theme
theme.layout_tile = config_path .. "icons/layout/tile.png"
theme.layout_tileleft = config_path .. "icons/layout/tileleft.png"
theme.layout_tilebottom = config_path .. "icons/layout/tilebottom.png"
theme.layout_tiletop = config_path .. "icons/layout/tiletop.png"
theme.layout_fairv = config_path .. "icons/layout/fairv.png"
theme.layout_fairh = config_path .. "icons/layout/fairh.png"
theme.layout_spiral = config_path .. "icons/layout/spiral.png"
theme.layout_dwindle = config_path .. "icons/layout/dwindle.png"
theme.layout_max = config_path .. "icons/layout/max.png"
theme.layout_fullscreen = config_path .. "icons/layout/fullscreen.png"
theme.layout_magnifier = config_path .. "icons/layout/magnifier.png"
theme.layout_floating = config_path .. "icons/layout/floating.png"
theme.layout_cornernw = themes_path .. "zenburn/layouts/cornernw.png"
theme.layout_cornerne = themes_path .. "zenburn/layouts/cornerne.png"
theme.layout_cornersw = themes_path .. "zenburn/layouts/cornersw.png"
theme.layout_cornerse = themes_path .. "zenburn/layouts/cornerse.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus = config_path .. "icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal = config_path .. "icons/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active = config_path .. "icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = config_path .. "icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive = config_path .. "icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = config_path .. "icons/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active = config_path .. "icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = config_path .. "icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive = config_path .. "icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = config_path .. "icons/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active = config_path .. "icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = config_path .. "icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive = config_path .. "icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = config_path .. "icons/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active = config_path .. "icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = config_path .. "icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive = config_path .. "icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = config_path .. "icons/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
