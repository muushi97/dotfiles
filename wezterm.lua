local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- WSL
config.default_domain = 'WSL:Ubuntu'
config.automatically_reload_config = true
config.use_ime = true

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Font
--config.font = wezterm.font_with_fallback {
--  'FiraCode Nerd Font',
--  'Noto Sans CJK JP', -- 日本語フォールバック
--}
config.font_size = 9.0

-- Window size
config.initial_cols = 220
config.initial_rows = 50

-- Scrollback
config.scrollback_lines = 10000

-- Mouse
config.pane_focus_follows_mouse = true

-- Key bindings
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- ペイン分割
  { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER',       action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },
  -- ペイン移動 (vim風)
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left'  },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down'  },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up'    },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  -- ペインを閉じる
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },
  -- ペインのズーム
  { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState },
  -- タブ操作
  { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1)  },
  { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
}

-- Status bar (右上に時刻を表示)
wezterm.on('update-right-status', function(window, _pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M'
  window:set_right_status(wezterm.format {
    { Foreground = { AnsiColor = 'Silver' } },
    { Text = date .. '  ' },
  })
end)

return config

