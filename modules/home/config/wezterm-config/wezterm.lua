local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13
config.window_background_opacity = 0.78
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Tokyo Night"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

return config
