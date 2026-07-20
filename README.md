# dotfiles

- `./install.sh install` でシンボリックリンクを張る
- WSL 環境では Windows 側にも設定ファイルをコピーする
- `links.linux` / `links.windows` でリンク・コピー先を管理

## サブコマンド

- `clone` : リポジトリを ~/dotfiles へ clone
- `install` : dotfiles をインストール（WSL では Windows 側も対象）
- `update` : dotfiles を更新
- `check` : 各コマンドのインストール状況を確認
- `help` : 使い方を表示
