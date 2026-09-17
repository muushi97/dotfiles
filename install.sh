#!/bin/sh

DOTFILES_REPOSITORY=https://github.com/muushi97/dotfiles.git
DOTFILES_PATH=~/dotfiles

# WSL 環境で Windows 側パス（/mnt/ 配下）を除外しながら、
# 外部コマンドまたは組込みコマンドが存在するか確認する
exist_command() {
    local result
    result=$(command -v "$1" 2>/dev/null) || return 1
    case "$result" in
        alias\ *) return 1 ;;              # エイリアスは除外
        /*)       printf '%s\n' "$result" | grep -qv '^/mnt/' ;;  # 外部コマンド: WSL フィルタ
        *)        return 0 ;;              # 組込みコマンド
    esac
}

# エイリアスが存在するか確認する
exist_alias() {
    command -v "$1" 2>/dev/null | grep -q '^alias '
}

# 組込みコマンドのみ存在するか確認する
exist_builtin() {
    local result
    result=$(command -v "$1" 2>/dev/null) || return 1
    case "$result" in
        /*|alias\ *) return 1 ;;
        *)           return 0 ;;
    esac
}

# シェル関数が存在するか確認する
# command -v はシェルによって出力が異なるため type を使用する
exist_function() {
    type "$1" 2>/dev/null | grep -q 'function'
}

# dotfiles リポジトリが未取得であれば GitHub から clone する
cmd_clone() {
    if [ -d "$DOTFILES_PATH" ]; then
        echo "$DOTFILES_PATH: already exists" >&2
        exit 1
    fi

    if ! exist_command git; then
        echo "git is not installed." >&2
        exit 1
    fi

    git clone --recursive "$DOTFILES_REPOSITORY" "$DOTFILES_PATH"
}

# link.yaml の1エントリに対応するシンボリックリンクを作成する
# $1: 依存コマンド名, $2: リンク先パス（$HOME 相対）, $3: リンク元パス（$DOTFILES_PATH 相対）
create_link() {
    local cmd="$1"
    local dest="$HOME/$2"
    local src="$DOTFILES_PATH/$3"

    if ! exist_command "$cmd"; then
        echo "$cmd is not installed, skipping."
        return
    fi

    if [ -e "$dest" ]; then
        echo "$dest: already exists, skipping."
        return
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "Linked: $src -> $dest"
}

# links ファイルを読んで各エントリのシンボリックリンクを作成する
link_dotfiles() {
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        create_link "$cmd" "$dest" "$src"
    done < "$DOTFILES_PATH/links.linux"
}

# vim プラグインを ~/.vim/pack/ 以下に clone する
install_vim_plugins() {
    local vimplugin_dir=~/.vim/pack
    git clone https://github.com/lilydjwg/colorizer.git "$vimplugin_dir/colorizer/start/colorizer"
    git clone https://github.com/scrooloose/nerdtree.git "$vimplugin_dir/nerdtree/start/nerdtree"
    git clone https://github.com/cocopon/pgmnt.vim.git   "$vimplugin_dir/pgmnt/start/pgmnt"
}

# vim プラグインを pull --rebase で最新化する
update_vim_plugins() {
    local vimplugin_dir=~/.vim/pack
    git -C "$vimplugin_dir/colorizer/start/colorizer" pull --rebase
    git -C "$vimplugin_dir/nerdtree/start/nerdtree"  pull --rebase
    git -C "$vimplugin_dir/pgmnt/start/pgmnt"        pull --rebase
}

# git 補完スクリプトを取得する
install_git_completion() {
    local git_version="2.5.0"
    local base_url="https://raw.githubusercontent.com/git/git/v${git_version}/contrib/completion"
    curl "$base_url/git-completion.bash" > ~/.git-completion.bash
    curl "$base_url/git-prompt.sh"       > ~/.git-prompt.sh
}

# Claude Code スキルを $DOTFILES_PATH/assets/claude/skills/ へダウンロードする
prepare_claude_skills() {
    local skill_dir="$DOTFILES_PATH/assets/claude/skills"
    local gist_urls="
https://gist.githubusercontent.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d/raw/SKILL.md
https://gist.githubusercontent.com/k16shikano/eb2929f13ed19c97188393d297be8432/raw/SKILL.md
"
    for url in $gist_urls; do
        local tmp
        tmp=$(mktemp)
        if ! curl -fsSL -o "$tmp" "$url"; then
            echo "Failed to download: $url" >&2
            rm -f "$tmp"
            continue
        fi
        local name
        name=$(awk '/^---/{c++; next} c==1 && /^name:/{print $2; exit}' "$tmp")
        if [ -z "$name" ]; then
            echo "Could not extract skill name from: $url" >&2
            rm -f "$tmp"
            continue
        fi
        mkdir -p "$skill_dir/$name"
        mv "$tmp" "$skill_dir/$name/SKILL.md"
        echo "Prepared Claude skill: $skill_dir/$name/SKILL.md"
    done
}

# 事前ダウンロード済みの Claude Code スキルを ~/.claude/skills/ へリンクする
deploy_claude_skills() {
    local skill_dir="$DOTFILES_PATH/assets/claude/skills"
    mkdir -p ~/.claude/skills
    for d in "$skill_dir"/*/; do
        create_link "claude" ".claude/skills/$(basename "$d")" "assets/claude/skills/$(basename "$d")"
    done
}

# wezterm フォントを $DOTFILES_PATH/assets/wezterm/fonts/ へダウンロードする
prepare_wezterm_fonts() {
    local font_url="https://int10h.org/oldschool-pc-fonts/download/oldschool_pc_font_pack_v2.2_linux.zip"
    local asset_dir="$DOTFILES_PATH/assets/wezterm/fonts"
    local zip_wsl_path
    zip_wsl_path=$(mktemp --suffix=.zip)

    curl.exe -fsSL -o "$(wslpath -w "$zip_wsl_path")" "$font_url" \
        || { echo "Failed to download fonts." >&2; rm -f "$zip_wsl_path"; return 1; }
    mkdir -p "$asset_dir"
    unzip -j "$zip_wsl_path" '*Px437*VGA*8x16*' -d "$asset_dir" \
        || { echo "Failed to extract fonts." >&2; rm -f "$zip_wsl_path"; return 1; }
    rm -f "$zip_wsl_path"
    echo "Prepared wezterm fonts in $asset_dir"
}

# 事前ダウンロード済みの wezterm フォントを Windows 側へコピーする
deploy_wezterm_fonts() {
    local asset_dir="$DOTFILES_PATH/assets/wezterm/fonts"
    local dest_dir
    dest_dir="$(resolve_win_home)/.config/wezterm/fonts"

    if ! exist_win_command wezterm; then
        echo "wezterm is not installed on Windows, skipping."
        return
    fi

    if [ ! -d "$asset_dir" ] || [ -z "$(ls -A "$asset_dir" 2>/dev/null)" ]; then
        echo "wezterm fonts not prepared. Run '$(basename "$0") prepare' first." >&2
        return 1
    fi

    mkdir -p "$dest_dir"
    cp "$asset_dir"/* "$dest_dir/"
    echo "Deployed wezterm fonts to $dest_dir"
}

# WSL 環境かどうかを確認する
is_wsl() {
    grep -qi 'microsoft\|wsl' /proc/sys/kernel/osrelease 2>/dev/null
}

# WSL から Windows のホームディレクトリパスを取得する
resolve_win_home() {
    wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')"
}

# Windows 側の PATH にコマンドが存在するか確認する
exist_win_command() {
    cmd.exe /c "where $1" > /dev/null 2>&1
}

# links.windows の dest パスから .base/.conflict ファイルのキーを作る
win_deploy_key() {
    printf '%s' "$1" | tr '/' '__'
}

# links.windows から指定キー（dest パス由来）に対応するエントリを探し、
# "cmd dest src" を出力する
find_win_link_entry() {
    local key="$1"
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        if [ "$(win_deploy_key "$dest")" = "$key" ]; then
            printf '%s %s %s\n' "$cmd" "$dest" "$src"
            return 0
        fi
    done < "$DOTFILES_PATH/links.windows"
    return 1
}

# links.windows の1エントリについて、Windows側の配置先とリポジトリ側の src を
# 前回同期時点（win-deploy-base/*.base）を基準に3-wayマージし、両方に反映する
# $1: 依存コマンド名, $2: 配置先パス（Windows ホーム相対）, $3: リポジトリ側パス（DOTFILES_PATH 相対）
sync_win_dotfile() {
    local cmd="$1"
    local dest_rel="$2"
    local src_rel="$3"
    local dest="$(resolve_win_home)/$dest_rel"
    local src="$DOTFILES_PATH/$src_rel"
    local base_dir="$DOTFILES_PATH/win-deploy-base"
    local key
    key="$(win_deploy_key "$dest_rel")"
    local base_file="$base_dir/$key.base"
    local conflict_file="$base_dir/$key.conflict"

    if ! exist_win_command "$cmd"; then
        echo "$cmd is not installed on Windows, skipping."
        return
    fi

    if [ -e "$conflict_file" ]; then
        echo "$dest_rel: conflict pending, resolve it first: $(basename "$0") resolve-win $key"
        return
    fi

    mkdir -p "$base_dir" "$(dirname "$dest")"

    if [ ! -e "$dest" ]; then
        cp "$src" "$dest"
        cp "$src" "$base_file"
        echo "Copied: $src -> $dest"
        return
    fi

    if [ ! -e "$base_file" ]; then
        cp "$dest" "$base_file"
        echo "$dest_rel: baseline established from existing file, no merge performed this run."
        return
    fi

    local dest_changed=1
    local src_changed=1
    cmp -s "$dest" "$base_file" && dest_changed=0
    cmp -s "$src" "$base_file" && src_changed=0

    if [ "$dest_changed" -eq 0 ] && [ "$src_changed" -eq 0 ]; then
        return
    fi

    if [ "$dest_changed" -eq 0 ] && [ "$src_changed" -eq 1 ]; then
        cp "$src" "$dest"
        cp "$src" "$base_file"
        echo "Updated: $src -> $dest"
        return
    fi

    if [ "$dest_changed" -eq 1 ] && [ "$src_changed" -eq 0 ]; then
        cp "$dest" "$src"
        cp "$dest" "$base_file"
        echo "Synced back: $dest -> $src"
        return
    fi

    # 両方が変更されている場合は base を祖先として3-wayマージする
    local merged
    merged="$(mktemp)"
    if git merge-file -p "$dest" "$base_file" "$src" > "$merged" 2>/dev/null; then
        cp "$merged" "$dest"
        cp "$merged" "$src"
        cp "$merged" "$base_file"
        rm -f "$merged"
        echo "Merged: $dest_rel"
    else
        cp "$merged" "$conflict_file"
        rm -f "$merged"
        echo "$dest_rel: merge conflict, resolve $conflict_file then run: $(basename "$0") resolve-win $key"
    fi
}

# links.windows を読んで Windows 側とリポジトリ側を同期する
deploy_win_dotfiles() {
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        sync_win_dotfile "$cmd" "$dest" "$src"
    done < "$DOTFILES_PATH/links.windows"
}

# resolve-win サブコマンド: コンフリクトを解消したファイルを配置先・リポジトリ側の両方へ反映する
# $1: win_deploy_key で得られるキー
cmd_resolve_win() {
    local key="$1"
    local base_dir="$DOTFILES_PATH/win-deploy-base"
    local conflict_file="$base_dir/$key.conflict"
    local base_file="$base_dir/$key.base"

    if [ ! -e "$conflict_file" ]; then
        echo "$key: no pending conflict ($conflict_file not found)" >&2
        exit 1
    fi

    if grep -q '^<<<<<<<' "$conflict_file"; then
        echo "$key: conflict markers remain in $conflict_file, resolve them first" >&2
        exit 1
    fi

    local entry
    if ! entry="$(find_win_link_entry "$key")"; then
        echo "$key: no matching entry in links.windows" >&2
        exit 1
    fi
    local cmd dest_rel src_rel
    read -r cmd dest_rel src_rel <<EOF
$entry
EOF
    local dest="$(resolve_win_home)/$dest_rel"
    local src="$DOTFILES_PATH/$src_rel"

    cp "$conflict_file" "$dest"
    cp "$conflict_file" "$src"
    cp "$conflict_file" "$base_file"
    rm -f "$conflict_file"
    echo "Resolved: $key"
}

# 必要なファイルを事前生成・ダウンロードする
cmd_prepare() {
    prepare_claude_skills
    if is_wsl; then
        prepare_wezterm_fonts
    fi
}

# シンボリックリンクを張り、vim プラグインと git 補完スクリプトをインストールする
# WSL 環境では Windows 側へのコピーも行う
cmd_apply() {
    link_dotfiles
    #install_vim_plugins
    #install_git_completion
    deploy_claude_skills
    if is_wsl; then
        deploy_win_dotfiles
        deploy_wezterm_fonts
    fi
}

# シンボリックリンクを更新し、vim プラグインを最新化する
cmd_update() {
    link_dotfiles
    #update_vim_plugins
}

# status サブコマンドの分類結果を一時ファイルに1行追記する
# $1: カテゴリキー, $2: 出力行
_status_add() {
    printf '%s\n' "$2" >> "$STATUS_TMP_DIR/$1"
}

# カテゴリファイルに内容があれば見出し付きで出力する
# $1: 見出し, $2: カテゴリキー
_status_print() {
    local file="$STATUS_TMP_DIR/$2"
    if [ -s "$file" ]; then
        echo "$1"
        sed 's/^/  /' "$file"
        echo
    fi
}

# links.linux の各エントリについて、シンボリックリンクの状態を分類する
check_link_status_linux() {
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        local dest_path="$HOME/$dest"
        local src_path="$DOTFILES_PATH/$src"

        if ! exist_command "$cmd"; then
            _status_add skipped "$cmd -> $dest"
            continue
        fi

        if [ -L "$dest_path" ]; then
            if [ "$(readlink "$dest_path")" = "$src_path" ]; then
                _status_add linked "$dest"
            else
                _status_add conflict "$dest (points elsewhere: $(readlink "$dest_path"))"
            fi
        elif [ -e "$dest_path" ]; then
            _status_add conflict "$dest (existing file, not a symlink)"
        else
            _status_add not_linked "$dest"
        fi
    done < "$DOTFILES_PATH/links.linux"
}

# links.windows の各エントリについて、sync_win_dotfile と同じ基準で
# 同期状態を副作用なしに分類する
check_link_status_windows() {
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        local dest_path="$(resolve_win_home)/$dest"
        local src_path="$DOTFILES_PATH/$src"
        local key base_file conflict_file
        key="$(win_deploy_key "$dest")"
        base_file="$DOTFILES_PATH/win-deploy-base/$key.base"
        conflict_file="$DOTFILES_PATH/win-deploy-base/$key.conflict"

        if ! exist_win_command "$cmd"; then
            _status_add win_skipped "$cmd -> $dest"
            continue
        fi

        if [ -e "$conflict_file" ]; then
            _status_add win_conflict "$dest (resolve-win $key)"
            continue
        fi

        if [ ! -e "$dest_path" ]; then
            _status_add win_not_deployed "$dest"
            continue
        fi

        if [ ! -e "$base_file" ]; then
            _status_add win_no_baseline "$dest"
            continue
        fi

        local dest_changed=1
        local src_changed=1
        cmp -s "$dest_path" "$base_file" && dest_changed=0
        cmp -s "$src_path" "$base_file" && src_changed=0

        if [ "$dest_changed" -eq 0 ] && [ "$src_changed" -eq 0 ]; then
            _status_add win_in_sync "$dest"
        elif [ "$dest_changed" -eq 0 ]; then
            _status_add win_needs_sync_src "$dest (repository side changed)"
        elif [ "$src_changed" -eq 0 ]; then
            _status_add win_needs_sync_dest "$dest (deployed side changed)"
        else
            _status_add win_needs_sync_both "$dest (both sides changed, will attempt auto-merge)"
        fi
    done < "$DOTFILES_PATH/links.windows"
}

# dotfiles のリンク・同期状態を git status のようにグループ分けして表示する
cmd_status() {
    STATUS_TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$STATUS_TMP_DIR"' EXIT

    check_link_status_linux
    echo "[links.linux]"
    _status_print "Linked:" linked
    _status_print "Not linked:" not_linked
    _status_print "Conflict (existing file is not our symlink):" conflict
    _status_print "Skipped (command not installed):" skipped

    if is_wsl; then
        check_link_status_windows
        echo "[links.windows]"
        _status_print "In sync:" win_in_sync
        _status_print "Needs sync (repository side changed):" win_needs_sync_src
        _status_print "Needs sync (deployed side changed):" win_needs_sync_dest
        _status_print "Needs sync (both sides changed):" win_needs_sync_both
        _status_print "Conflict pending:" win_conflict
        _status_print "Not deployed:" win_not_deployed
        _status_print "No baseline yet (run apply once):" win_no_baseline
        _status_print "Skipped (command not installed on Windows):" win_skipped
    fi

    rm -rf "$STATUS_TMP_DIR"
    trap - EXIT
}

# links.linux の Conflict エントリ（既存ファイルが symlink でない）について
# 「既存ファイル」と「リポジトリ側ファイル」の diff を出力先ファイルへ書き出す
# $1: 出力先ファイル
diff_conflicts_linux() {
    local out="$1"
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        local dest_path="$HOME/$dest"
        local src_path="$DOTFILES_PATH/$src"

        if ! exist_command "$cmd"; then
            continue
        fi
        if [ -L "$dest_path" ] || [ ! -e "$dest_path" ]; then
            continue
        fi

        if [ -d "$dest_path" ]; then
            {
                echo "=== conflict: $dest (directory, skipping content diff) ==="
                echo
            } >> "$out"
            continue
        fi

        {
            echo "=== conflict: $dest ==="
            diff -u --label "existing: $dest" --label "repository: $src" "$dest_path" "$src_path"
            echo
        } >> "$out"
    done < "$DOTFILES_PATH/links.linux"
}

# links.windows の Needs sync / Conflict pending エントリについて
# base を基準にした diff を出力先ファイルへ書き出す
# $1: 出力先ファイル
diff_pending_windows() {
    local out="$1"
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        local dest_path="$(resolve_win_home)/$dest"
        local src_path="$DOTFILES_PATH/$src"
        local key base_file conflict_file
        key="$(win_deploy_key "$dest")"
        base_file="$DOTFILES_PATH/win-deploy-base/$key.base"
        conflict_file="$DOTFILES_PATH/win-deploy-base/$key.conflict"

        if ! exist_win_command "$cmd"; then
            continue
        fi

        if [ -e "$conflict_file" ]; then
            {
                echo "=== conflict pending: $dest (resolve-win $key) ==="
                echo "--- base vs deployed ---"
                diff -u --label "base" --label "deployed: $dest" "$base_file" "$dest_path"
                echo "--- base vs repository ---"
                diff -u --label "base" --label "repository: $src" "$base_file" "$src_path"
                echo
            } >> "$out"
            continue
        fi

        if [ ! -e "$dest_path" ] || [ ! -e "$base_file" ]; then
            continue
        fi

        local dest_changed=1
        local src_changed=1
        cmp -s "$dest_path" "$base_file" && dest_changed=0
        cmp -s "$src_path" "$base_file" && src_changed=0

        if [ "$dest_changed" -eq 0 ] && [ "$src_changed" -eq 0 ]; then
            continue
        fi

        {
            echo "=== needs sync: $dest ==="
            if [ "$dest_changed" -eq 1 ]; then
                echo "--- base vs deployed ---"
                diff -u --label "base" --label "deployed: $dest" "$base_file" "$dest_path"
            fi
            if [ "$src_changed" -eq 1 ]; then
                echo "--- base vs repository ---"
                diff -u --label "base" --label "repository: $src" "$base_file" "$src_path"
            fi
            echo
        } >> "$out"
    done < "$DOTFILES_PATH/links.windows"
}

# dotfiles の未同期・衝突エントリについて具体的な内容差分を表示する
cmd_diff() {
    DIFF_TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$DIFF_TMP_DIR"' EXIT

    local linux_out="$DIFF_TMP_DIR/linux"
    : > "$linux_out"
    diff_conflicts_linux "$linux_out"
    if [ -s "$linux_out" ]; then
        echo "[links.linux]"
        cat "$linux_out"
    fi

    if is_wsl; then
        local win_out="$DIFF_TMP_DIR/windows"
        : > "$win_out"
        diff_pending_windows "$win_out"
        if [ -s "$win_out" ]; then
            echo "[links.windows]"
            cat "$win_out"
        fi
    fi

    rm -rf "$DIFF_TMP_DIR"
    trap - EXIT
}

# links ファイル内の各コマンドの存在をチェックして結果を表示する
cmd_check() {
    awk '!/^[[:space:]]*(#|$)/ { print $1 }' "$DOTFILES_PATH/links.linux" | sort -u | \
        while IFS= read -r cmd; do
            if exist_command "$cmd"; then
                echo "[ installed ] $cmd"
            else
                echo "[ not found ] $cmd"
            fi
        done

    if is_wsl; then
        awk '!/^[[:space:]]*(#|$)/ { print $1 }' "$DOTFILES_PATH/links.windows" | sort -u | \
            while IFS= read -r cmd; do
                if exist_win_command "$cmd"; then
                    echo "[ installed ] $cmd (win)"
                else
                    echo "[ not found ] $cmd (win)"
                fi
            done
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") <subcommand>

Subcommands:
  clone               リポジトリを ~/dotfiles へ clone する
  prepare             必要なファイルを事前ダウンロード・生成する（WSL では wezterm フォントも取得）
  apply               dotfiles を環境へ適用する（WSL 環境では Windows 側も対象）
  update              dotfiles を更新する
  check               各コマンドのインストール状況を確認する
  status              dotfiles のリンク・同期状態を確認する
  diff                未同期・衝突エントリの内容差分を表示する
  resolve-win <key>   Windows側配置ファイルのマージコンフリクトを解消する
  help                この使い方を表示する
EOF
}

case "$#" in
    0) usage ;;
    1)
        case "$1" in
            clone)   cmd_clone ;;
            prepare) cmd_prepare ;;
            apply)   cmd_apply ;;
            update)  cmd_update ;;
            check)   cmd_check ;;
            status)  cmd_status ;;
            diff)    cmd_diff ;;
            help)    usage ;;
            *)       usage >&2; exit 1 ;;
        esac
        ;;
    2)
        case "$1" in
            resolve-win) cmd_resolve_win "$2" ;;
            *)           usage >&2; exit 1 ;;
        esac
        ;;
    *) usage >&2; exit 1 ;;
esac
