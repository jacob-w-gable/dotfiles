local settings = require("../settings")

local gears = require("gears")
local themes_path = require("gears.filesystem").get_themes_dir()
local config_path = require("gears.filesystem").get_configuration_dir()
local dpi = require("beautiful.xresources").apply_dpi

local layout_icons_path = config_path .. "theme/icons/layout/"
local titlebar_icons_path = config_path .. "theme/icons/titlebar/"

-- {{{ Main
local theme = {}
theme.wallpaper = config_path .. settings.style.wallpaper
-- }}}

-- {{{ Styles
theme.font = "Hack Nerd Font 8"

-- {{{ Colors
theme.fg_normal = settings.style.secondary_color
theme.fg_focus = settings.style.primary_color
theme.fg_urgent = settings.style.secondary_color
theme.bg_normal = settings.style.background_color
theme.bg_focus = settings.style.highlight_color
theme.bg_urgent = settings.style.highlight_color
theme.bg_systray = theme.bg_normal
theme.prompt_bg = "#00000000" -- Transparent
-- }}}

-- {{{ Borders
theme.useless_gap = dpi(3)
theme.border_width = dpi(1)
theme.border_normal = settings.style.background_color
theme.border_focus = settings.style.highlight_color
theme.border_marked = settings.style.highlight_color
-- }}}

theme.notification_shape = gears.shape.rounded_rect
theme.notification_bg = settings.style.background_color
theme.notification_border_color = settings.style.highlight_color
if settings.opacity then
	theme.notification_bg = theme.notification_bg .. "B3"
	theme.notification_border_color = theme.notification_border_color .. "B3"
end

-- {{{ Titlebars
theme.titlebar_bg_focus = settings.style.highlight_color
if settings.opacity then
	theme.titlebar_bg_focus = theme.titlebar_bg_focus .. "D9"
end
theme.titlebar_bg_normal = settings.style.background_color
if settings.opacity then
	theme.titlebar_bg_normal = theme.titlebar_bg_normal .. "D9"
end
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- }}}

-- {{{ Menu
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)
-- }}}

-- {{{ Misc
theme.awesome_icon = themes_path .. "zenburn/awesome-icon.png"
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
-- }}}

-- {{{ Layout
-- Theses are sourced from the multicolor theme
theme.layout_tile = layout_icons_path .. "tile.png"
theme.layout_tileleft = layout_icons_path .. "tileleft.png"
theme.layout_tilebottom = layout_icons_path .. "tilebottom.png"
theme.layout_tiletop = layout_icons_path .. "tiletop.png"
theme.layout_fairv = layout_icons_path .. "fairv.png"
theme.layout_fairh = layout_icons_path .. "fairh.png"
theme.layout_spiral = layout_icons_path .. "spiral.png"
theme.layout_dwindle = layout_icons_path .. "dwindle.png"
theme.layout_max = layout_icons_path .. "max.png"
theme.layout_fullscreen = layout_icons_path .. "fullscreen.png"
theme.layout_magnifier = layout_icons_path .. "magnifier.png"
theme.layout_floating = layout_icons_path .. "floating.png"
theme.layout_cornernw = themes_path .. "zenburn/layouts/cornernw.png"
theme.layout_cornerne = themes_path .. "zenburn/layouts/cornerne.png"
theme.layout_cornersw = themes_path .. "zenburn/layouts/cornersw.png"
theme.layout_cornerse = themes_path .. "zenburn/layouts/cornerse.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus = titlebar_icons_path .. "close_focus.png"
theme.titlebar_close_button_normal = titlebar_icons_path .. "close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active = titlebar_icons_path .. "ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = titlebar_icons_path .. "ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive = titlebar_icons_path .. "ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = titlebar_icons_path .. "ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active = titlebar_icons_path .. "sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = titlebar_icons_path .. "sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive = titlebar_icons_path .. "sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = titlebar_icons_path .. "sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active = titlebar_icons_path .. "floating_focus_active.png"
theme.titlebar_floating_button_normal_active = titlebar_icons_path .. "floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive = titlebar_icons_path .. "floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = titlebar_icons_path .. "floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active = titlebar_icons_path .. "maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = titlebar_icons_path .. "maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive = titlebar_icons_path .. "maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = titlebar_icons_path .. "maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
