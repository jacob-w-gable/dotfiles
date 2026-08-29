-- Notification placement and spacing.

local naughty = require("naughty")
local dpi = require("beautiful.xresources").apply_dpi

naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.margin = 15
naughty.config.padding = dpi(25)
naughty.config.spacing = dpi(10)
