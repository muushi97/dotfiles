# dotfiles

- `./install.sh clone` でリポジトリを ~/dotfiles へ clone する
- `./install.sh prepare` で事前ダウンロード・生成が必要なファイル（Claude Code スキル、WSL では wezterm フォント）を用意する
- `./install.sh apply` でシンボリックリンクを張る（WSL 環境では Windows 側にも設定ファイルをコピーする）
- `links.linux` / `links.windows` でリンク・コピー先を管理

## サブコマンド

- `clone`   : リポジトリを ~/dotfiles へ clone
- `prepare` : 必要なファイルを事前ダウンロード・生成（WSL では wezterm フォントも取得）
- `apply`   : dotfiles を環境へ適用（WSL では Windows 側も対象）
- `update`  : dotfiles を更新
- `check`   : 各コマンドのインストール状況を確認
- `help`    : 使い方を表示
