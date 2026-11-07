# dotfiles

- `./install.sh clone` でリポジトリを ~/dotfiles へ clone する
- `./install.sh prepare` で事前ダウンロード・生成が必要なファイル（Claude Code スキル、WSL では wezterm フォント）を用意する
- `./install.sh apply` でシンボリックリンクを張り、コピーで配置するファイルを同期する（WSL 環境では Windows 側にも同期する）
- `links.linux` でシンボリックリンクで配置するファイルを管理する
- `copy.linux`（配置先は Linux のホーム）/ `copy.windows`（配置先は Windows のホーム。WSL のときだけ対象）でコピーで配置するファイルを管理する。両者の違いは配置先だけで、同期の動作は同じ
  - `apply` / `update` のたびに、前回同期時点の内容（`copy-base/linux/`、`copy-base/windows/`）を基準に、配置先とリポジトリ側を3-wayで同期する
  - ディレクトリは中のファイルごとに同期し、片側での追加・削除も反映する
  - 初めての同期で配置先とリポジトリ側の両方にファイルがあり、中身が違う場合はコンフリクトとして扱う
## サブコマンド

- `clone`   : リポジトリを ~/dotfiles へ clone
- `prepare` : 必要なファイルを事前ダウンロード・生成（WSL では wezterm フォントも取得）
- `apply`   : dotfiles を環境へ適用（WSL では Windows 側も対象）
- `update`  : dotfiles を更新
- `check`   : 各コマンドのインストール状況を確認
- `resolve <key>`          : 同期のコンフリクトを解消した内容（`.conflict` ファイル）を、配置先とリポジトリ側の両方へ反映
- `resolve --delete <key>` : 削除と変更のコンフリクトを、配置先とリポジトリ側の両方から削除して解消
- `help`    : 使い方を表示
