local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.font_dirs = { wezterm.config_dir .. '/fonts' }

----------------------------------------------------------------
-- フォント: OSインストール不要で読み込む
----------------------------------------------------------------

-- Px437 IBM VGA8: 実機VGA BIOSの8x16ビットマップをそのまま復刻したフォント
-- (int10h.org "The Ultimate Oldschool PC Font Pack" より, CC BY-SA 4.0)
config.font = wezterm.font('Mx437 IBM VGA 8x16', { weight = 'Regular' })
config.font_rules = {
  {
    intensity = 'Bold',
    font = wezterm.font('Mx437 IBM VGA 8x16', { weight = 'Regular' }),
  },
}
-- 合字(リガチャ)を無効化
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
-- ビットマップの角をにじませない
config.freetype_load_target = 'Mono'
config.freetype_render_target = 'Mono'
-- フォント諸設定
config.font_size = 12.0  -- dpi 96 のときに 16px
config.line_height = 1.0
config.cell_width = 1.0
--config.front_end = "OpenGL"


----------------------------------------------------------------
-- 配色: 昔ながらのVGAテキストモード16色パレット
----------------------------------------------------------------

config.colors = {
  foreground = '#AAAAAA', -- 標準テキスト(古いDOSプロンプトのライトグレー)
  background = '#000000',
  cursor_bg = '#AAAAAA',
  cursor_fg = '#000000',
  cursor_border = '#AAAAAA',
  selection_fg = '#000000',
  selection_bg = '#AAAAAA',
 
  ansi = {
    '#000000', -- black
    '#AA0000', -- red
    '#00AA00', -- green
    '#AA5500', -- brown/yellow
    '#0000AA', -- blue
    '#AA00AA', -- magenta
    '#00AAAA', -- cyan
    '#AAAAAA', -- light gray
  },
  brights = {
    '#555555', -- dark gray
    '#FF5555', -- light red
    '#55FF55', -- light green
    '#FFFF55', -- yellow
    '#5555FF', -- light blue
    '#FF55FF', -- light magenta
    '#55FFFF', -- light cyan
    '#FFFFFF', -- white
  },
}


----------------------------------------------------------------
-- カーソル: 古い端末らしい点滅ブロックカーソル
----------------------------------------------------------------
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'


----------------------------------------------------------------
-- ウィンドウまわり: 余計な装飾を削ぎ落とす
----------------------------------------------------------------

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.window_background_opacity = 1.0
config.enable_scroll_bar = true
 
-- タブバーもレトロな見た目に
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true


----------------------------------------------------------------
-- WSL まわりの設定
----------------------------------------------------------------

config.default_domain = 'WSL:Ubuntu'
config.automatically_reload_config = true


----------------------------------------------------------------
-- ...
----------------------------------------------------------------

-- 初期ウィンドウサイズ (文字数)
config.initial_cols = 80
config.initial_rows = 25

-- Scrollback
config.scrollback_lines = 10000

-- Mouse
config.pane_focus_follows_mouse = true

-- IME
config.use_ime = true


----------------------------------------------------------------
-- キーバインド
----------------------------------------------------------------

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


----------------------------------------------------------------
-- ステータスバー
----------------------------------------------------------------

wezterm.on('update-right-status', function(window, _pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M'
  window:set_right_status(wezterm.format {
    { Foreground = { AnsiColor = 'Silver' } },
    { Text = date .. '  ' },
  })
end)

return config

