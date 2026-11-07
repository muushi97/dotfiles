#!/bin/sh

DOTFILES_REPOSITORY=https://github.com/muushi97/dotfiles.git
DOTFILES_PATH=~/dotfiles
COPY_BASE_DIR="$DOTFILES_PATH/copy-base"

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

# 事前ダウンロード済みの Claude Code スキルを ~/.claude/skills/ へ一方向にコピーする
# 配置先での変更は書き戻さず、毎回 assets 側の内容で上書きする
deploy_claude_skills() {
    local skill_dir="$DOTFILES_PATH/assets/claude/skills"

    if ! exist_command claude; then
        echo "claude is not installed, skipping."
        return
    fi

    mkdir -p ~/.claude/skills
    for d in "$skill_dir"/*/; do
        [ -d "$d" ] || continue
        local src="${d%/}"
        local dest="$HOME/.claude/skills/$(basename "$src")"

        if [ -L "$dest" ]; then
            echo "$dest: symbolic link, remove it manually to deploy as a copy, skipping."
            continue
        fi

        mkdir -p "$dest"
        cp -r "$src/." "$dest/"
        echo "Copied: $src -> $dest"
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

# コピー配置の対象（linux / windows）について、配置先の起点ディレクトリを出力する
# $1: 対象
copy_dest_root() {
    case "$1" in
        linux)   printf '%s\n' "$HOME" ;;
        windows) resolve_win_home ;;
    esac
}

# コピー配置の対象について、コマンドが配置先の環境に存在するか確認する
# $1: 対象, $2: コマンド名
copy_exist_command() {
    case "$1" in
        linux)   exist_command "$2" ;;
        windows) exist_win_command "$2" ;;
    esac
}

# 配置先・リポジトリ側を前回同期時点の base と比べて同期状態を分類し、状態名を出力する
# $1: 配置先, $2: リポジトリ側, $3: base ファイル, $4: conflict ファイル,
# $5: 1 なら片側での削除も同期の対象にする
classify_3way() {
    local dest="$1"
    local src="$2"
    local base_file="$3"
    local conflict_file="$4"
    local track_delete="$5"

    if [ -e "$conflict_file" ]; then
        echo conflict
        return
    fi

    # base があるのに片側にないファイルは、その側で削除されたとみなす
    if [ "$track_delete" -eq 1 ] && [ -e "$base_file" ]; then
        if [ ! -e "$dest" ] && [ ! -e "$src" ]; then
            echo deleted_both
            return
        fi
        if [ ! -e "$dest" ]; then
            if cmp -s "$src" "$base_file"; then
                echo deleted_dest
            else
                echo deleted_dest_conflict
            fi
            return
        fi
        if [ ! -e "$src" ]; then
            if cmp -s "$dest" "$base_file"; then
                echo deleted_src
            else
                echo deleted_src_conflict
            fi
            return
        fi
    fi

    if [ ! -e "$dest" ]; then
        if [ -e "$src" ]; then
            echo not_deployed
        else
            echo missing
        fi
        return
    fi

    if [ ! -e "$src" ]; then
        echo new_dest
        return
    fi

    # 初めての同期で両側にファイルがある場合、中身（と実行ビット）が違えば衝突として扱う
    if [ ! -e "$base_file" ]; then
        if cmp -s "$dest" "$src"; then
            echo no_baseline_same
        else
            echo no_baseline_differ
        fi
        return
    fi

    local dest_changed=1
    local src_changed=1
    cmp -s "$dest" "$base_file" && dest_changed=0
    cmp -s "$src" "$base_file" && src_changed=0

    if [ "$dest_changed" -eq 0 ] && [ "$src_changed" -eq 0 ]; then
        echo in_sync
    elif [ "$dest_changed" -eq 0 ]; then
        echo src_changed
    elif [ "$src_changed" -eq 0 ]; then
        echo dest_changed
    else
        echo both_changed
    fi
}

# 1ファイルについて、配置先とリポジトリ側を前回同期時点の base を基準に3-wayマージし、
# 両方に反映する
# $1: 配置先, $2: リポジトリ側, $3: base ファイル, $4: conflict ファイル,
# $5: resolve サブコマンドに渡すキー（配置先の相対パス）, $6: 1 なら片側での削除も同期する
sync_file_3way() {
    local dest="$1"
    local src="$2"
    local base_file="$3"
    local conflict_file="$4"
    local key="$5"
    local track_delete="$6"
    local label="$key"
    local state
    state="$(classify_3way "$dest" "$src" "$base_file" "$conflict_file" "$track_delete")"

    mkdir -p "$(dirname "$base_file")"

    case "$state" in
        conflict)
            echo "$label: conflict pending, resolve it first: $(basename "$0") resolve $key"
            ;;
        missing)
            echo "$label: missing on both sides, skipping."
            ;;
        deleted_both)
            rm -f "$base_file"
            echo "$label: removed on both sides, baseline cleared."
            ;;
        deleted_dest)
            rm -f "$src" "$base_file"
            echo "Deleted: $src (removed on deployed side)"
            ;;
        deleted_src)
            rm -f "$dest" "$base_file"
            echo "Deleted: $dest (removed in repository)"
            ;;
        deleted_dest_conflict)
            cp "$src" "$conflict_file"
            echo "$label: removed on deployed side but changed in repository, edit $conflict_file then run: $(basename "$0") resolve [--delete] $key"
            ;;
        deleted_src_conflict)
            cp "$dest" "$conflict_file"
            echo "$label: removed in repository but changed on deployed side, edit $conflict_file then run: $(basename "$0") resolve [--delete] $key"
            ;;
        not_deployed)
            mkdir -p "$(dirname "$dest")"
            cp "$src" "$dest"
            cp "$src" "$base_file"
            echo "Copied: $src -> $dest"
            ;;
        new_dest)
            mkdir -p "$(dirname "$src")"
            cp "$dest" "$src"
            cp "$dest" "$base_file"
            echo "Copied back: $dest -> $src"
            ;;
        no_baseline_same)
            cp "$dest" "$base_file"
            echo "$label: baseline established (both sides identical)."
            ;;
        no_baseline_differ)
            # 共通の祖先がないので、空ファイルを祖先として差分のある箇所に印を付ける
            local empty
            empty="$(mktemp)"
            git merge-file -p "$dest" "$empty" "$src" > "$conflict_file" 2>/dev/null
            rm -f "$empty"
            echo "$label: no baseline and both sides differ, resolve $conflict_file then run: $(basename "$0") resolve $key"
            ;;
        in_sync)
            ;;
        src_changed)
            cp "$src" "$dest"
            cp "$src" "$base_file"
            echo "Updated: $src -> $dest"
            ;;
        dest_changed)
            cp "$dest" "$src"
            cp "$dest" "$base_file"
            echo "Synced back: $dest -> $src"
            ;;
        both_changed)
            # 両方が変更されている場合は base を祖先として3-wayマージする
            local merged
            merged="$(mktemp)"
            if git merge-file -p "$dest" "$base_file" "$src" > "$merged" 2>/dev/null; then
                cp "$merged" "$dest"
                cp "$merged" "$src"
                cp "$merged" "$base_file"
                rm -f "$merged"
                echo "Merged: $label"
            else
                cp "$merged" "$conflict_file"
                rm -f "$merged"
                echo "$label: merge conflict, resolve $conflict_file then run: $(basename "$0") resolve $key"
            fi
            ;;
    esac
}

# ディレクトリエントリについて、配置先・リポジトリ側・base のいずれかにある
# ファイルの相対パスを重複なく出力する
# $1: 配置先ディレクトリ, $2: リポジトリ側ディレクトリ, $3: base ディレクトリ
list_copy_dir_files() {
    local dest="$1"
    local src="$2"
    local base="$3"
    {
        if [ -d "$src" ]; then
            (cd "$src" && find . -type f)
        fi
        if [ -d "$dest" ]; then
            (cd "$dest" && find . -type f)
        fi
        if [ -d "$base" ]; then
            (cd "$base" && find . -type f -name '*.base' | sed 's/\.base$//')
            (cd "$base" && find . -type f -name '*.conflict' | sed 's/\.conflict$//')
        fi
    } | sed 's|^\./||' | sort -u
}

# copy.<対象> の各エントリをファイル単位に展開し、ファイルごとにコールバックを呼ぶ
# ディレクトリエントリは中のファイルごとに展開し、片側での追加・削除も同期の対象にする
# コールバックの引数: 対象, 種別, 表示名, [配置先, リポジトリ側, base ファイル, conflict ファイル, 削除追跡]
#   種別 file    : 同期対象のファイル（表示名は配置先の相対パスで、resolve のキーを兼ねる）
#   種別 skipped : コマンドが配置先の環境にない
#   種別 symlink : 配置先がシンボリックリンク
#   種別 notdir  : リポジトリ側はディレクトリだが、配置先がディレクトリでない
# $1: 対象（linux / windows）, $2: コールバック関数名
foreach_copy_file() {
    local target="$1"
    local callback="$2"
    local root cmd dest_rel src_rel dest src base
    root="$(copy_dest_root "$target")"

    # コールバック内のコマンドが標準入力を読んでも対応表の読み込みに影響しないよう、fd 3 で読む
    while IFS=' ' read -r cmd dest_rel src_rel <&3; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        dest="$root/$dest_rel"
        src="$DOTFILES_PATH/$src_rel"
        base="$COPY_BASE_DIR/$target/$dest_rel"

        if ! copy_exist_command "$target" "$cmd"; then
            "$callback" "$target" skipped "$cmd -> $dest_rel"
            continue
        fi

        if [ -L "$dest" ]; then
            "$callback" "$target" symlink "$dest_rel"
            continue
        fi

        if [ -d "$src" ] || [ -d "$dest" ]; then
            if [ -e "$dest" ] && [ ! -d "$dest" ]; then
                "$callback" "$target" notdir "$dest_rel"
                continue
            fi
            list_copy_dir_files "$dest" "$src" "$base" | while IFS= read -r rel; do
                "$callback" "$target" file "$dest_rel/$rel" \
                    "$dest/$rel" "$src/$rel" "$base/$rel.base" "$base/$rel.conflict" 1
            done
        else
            "$callback" "$target" file "$dest_rel" \
                "$dest" "$src" "$base.base" "$base.conflict" 0
        fi
    done 3< "$DOTFILES_PATH/copy.$target"
}

# foreach_copy_file のコールバック: 1ファイルを同期する
_sync_copy_cb() {
    local target="$1"
    local kind="$2"
    local label="$3"
    case "$kind" in
        skipped) echo "[$target] $label: command not installed, skipping." ;;
        symlink) echo "[$target] $label: symbolic link, remove it manually to deploy as a copy, skipping." ;;
        notdir)  echo "[$target] $label: exists but is not a directory, skipping." ;;
        file)    sync_file_3way "$4" "$5" "$6" "$7" "$label" "$8" ;;
    esac
}

# copy.<対象> を読んで配置先とリポジトリ側を同期する
# $1: 対象（linux / windows）
deploy_copy_dotfiles() {
    foreach_copy_file "$1" _sync_copy_cb
}

# copy.<対象> から、指定キー（配置先の相対パス）を含むエントリを探し、
# "cmd dest src" を出力する
# $1: 対象, $2: キー
find_copy_entry() {
    local key="$2"
    local cmd dest src
    while IFS=' ' read -r cmd dest src; do
        case "$cmd" in
            ''|\#*) continue ;;
        esac
        case "$key" in
            "$dest"|"$dest"/*)
                printf '%s %s %s\n' "$cmd" "$dest" "$src"
                return 0
                ;;
        esac
    done < "$DOTFILES_PATH/copy.$1"
    return 1
}

# resolve サブコマンド: コンフリクトを解消したファイルを配置先・リポジトリ側の両方へ反映する
# 削除する場合は、配置先・リポジトリ側の両方から削除する
# $1: キー（配置先の相対パス）, $2: 1 なら削除する
cmd_resolve() {
    local key="$1"
    local delete="$2"
    local target="" t
    local conflict_file base_file dest src entry
    local cmd dest_rel src_rel

    for t in linux windows; do
        if [ -e "$COPY_BASE_DIR/$t/$key.conflict" ]; then
            if [ -n "$target" ]; then
                echo "$key: ambiguous, pending conflicts found for both linux and windows" >&2
                exit 1
            fi
            target="$t"
        fi
    done

    if [ -z "$target" ]; then
        echo "$key: no pending conflict" >&2
        exit 1
    fi

    if ! entry="$(find_copy_entry "$target" "$key")"; then
        echo "$key: no matching entry in copy.$target" >&2
        exit 1
    fi
    read -r cmd dest_rel src_rel <<EOF
$entry
EOF
    conflict_file="$COPY_BASE_DIR/$target/$key.conflict"
    base_file="$COPY_BASE_DIR/$target/$key.base"
    dest="$(copy_dest_root "$target")/$key"
    src="$DOTFILES_PATH/$src_rel${key#"$dest_rel"}"

    if [ "$delete" -eq 1 ]; then
        rm -f "$dest" "$src" "$base_file" "$conflict_file"
        echo "Resolved (deleted): $key"
        return
    fi

    if grep -q '^<<<<<<<' "$conflict_file"; then
        echo "$key: conflict markers remain in $conflict_file, resolve them first" >&2
        exit 1
    fi

    mkdir -p "$(dirname "$dest")" "$(dirname "$src")"
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

# シンボリックリンクを張り、copy.linux を同期し、vim プラグインと git 補完スクリプトをインストールする
# WSL 環境では copy.windows の同期と、Windows 側へのフォントのコピーも行う
cmd_apply() {
    link_dotfiles
    deploy_copy_dotfiles linux
    #install_vim_plugins
    #install_git_completion
    deploy_claude_skills
    if is_wsl; then
        deploy_copy_dotfiles windows
        deploy_wezterm_fonts
    fi
}

# シンボリックリンクを更新し、copy.linux を同期し、vim プラグインを最新化する
# WSL 環境では copy.windows の同期も行う
cmd_update() {
    link_dotfiles
    deploy_copy_dotfiles linux
    if is_wsl; then
        deploy_copy_dotfiles windows
    fi
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

# foreach_copy_file のコールバック: sync_file_3way と同じ基準で、1ファイルの同期状態を
# 副作用なしに分類して status の結果に追記する
_status_copy_cb() {
    local target="$1"
    local kind="$2"
    local label="$3"
    local state

    if [ "$kind" != file ]; then
        _status_add "${target}_$kind" "$label"
        return
    fi

    state="$(classify_3way "$4" "$5" "$6" "$7" "$8")"
    case "$state" in
        conflict)              _status_add "${target}_conflict" "$label (resolve $label)" ;;
        deleted_dest_conflict) _status_add "${target}_delete_vs_change" "$label (removed on deployed side, changed in repository)" ;;
        deleted_src_conflict)  _status_add "${target}_delete_vs_change" "$label (removed in repository, changed on deployed side)" ;;
        *)                     _status_add "${target}_$state" "$label" ;;
    esac
}

# copy.<対象> の同期状態を分類して見出し付きで表示する
# $1: 対象（linux / windows）
print_copy_status() {
    local t="$1"
    foreach_copy_file "$t" _status_copy_cb
    echo "[copy.$t]"
    _status_print "In sync:" "${t}_in_sync"
    _status_print "Needs sync (repository side changed):" "${t}_src_changed"
    _status_print "Needs sync (deployed side changed):" "${t}_dest_changed"
    _status_print "Needs sync (both sides changed, will attempt auto-merge):" "${t}_both_changed"
    _status_print "Needs sync (added on deployed side):" "${t}_new_dest"
    _status_print "Needs sync (removed on deployed side):" "${t}_deleted_dest"
    _status_print "Needs sync (removed in repository):" "${t}_deleted_src"
    _status_print "Needs sync (removed on one side, changed on the other; will conflict):" "${t}_delete_vs_change"
    _status_print "Removed on both sides (baseline only):" "${t}_deleted_both"
    _status_print "Conflict pending:" "${t}_conflict"
    _status_print "Not deployed:" "${t}_not_deployed"
    _status_print "Missing on both sides:" "${t}_missing"
    _status_print "No baseline yet, both sides identical (baseline will be created):" "${t}_no_baseline_same"
    _status_print "No baseline yet, both sides differ (will conflict):" "${t}_no_baseline_differ"
    _status_print "Symbolic link (remove it manually to deploy as a copy):" "${t}_symlink"
    _status_print "Not a directory on deployed side:" "${t}_notdir"
    _status_print "Skipped (command not installed):" "${t}_skipped"
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

    print_copy_status linux

    if is_wsl; then
        print_copy_status windows
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

# ファイルがあればそのパスを、なければ /dev/null を出力する（diff の引数用）
_path_or_null() {
    if [ -e "$1" ]; then
        printf '%s\n' "$1"
    else
        echo /dev/null
    fi
}

# foreach_copy_file のコールバック: 1ファイルが未同期・衝突なら、base を基準にした diff を出力する
# base がまだなく両側の中身が違う場合は、配置先とリポジトリ側の diff を出力する
_diff_copy_cb() {
    local kind="$2"
    local label="$3"
    local dest="$4"
    local src="$5"
    local base_file="$6"
    local state

    [ "$kind" = file ] || return 0
    state="$(classify_3way "$4" "$5" "$6" "$7" "$8")"

    case "$state" in
        in_sync|not_deployed|no_baseline_same|missing|deleted_both)
            return
            ;;
        no_baseline_differ)
            echo "=== needs sync: $label (no baseline, will conflict) ==="
            ;;
        conflict) echo "=== conflict pending: $label (resolve $label) ===" ;;
        *)        echo "=== needs sync: $label ===" ;;
    esac

    # base がない（初めての同期）場合は、配置先とリポジトリ側を直接比べる
    if [ ! -e "$base_file" ] && [ -e "$dest" ] && [ -e "$src" ]; then
        echo "--- deployed vs repository ---"
        diff -u --label "deployed: $label" --label "repository: $label" "$dest" "$src"
        echo
        return
    fi
    if { [ -e "$dest" ] || [ -e "$base_file" ]; } && ! cmp -s "$dest" "$base_file"; then
        echo "--- base vs deployed ---"
        diff -u --label "base" --label "deployed: $label" \
            "$(_path_or_null "$base_file")" "$(_path_or_null "$dest")"
    fi
    if { [ -e "$src" ] || [ -e "$base_file" ]; } && ! cmp -s "$src" "$base_file"; then
        echo "--- base vs repository ---"
        diff -u --label "base" --label "repository: $label" \
            "$(_path_or_null "$base_file")" "$(_path_or_null "$src")"
    fi
    echo
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

    local targets="linux"
    if is_wsl; then
        targets="linux windows"
    fi
    local t
    for t in $targets; do
        local copy_out="$DIFF_TMP_DIR/copy.$t"
        foreach_copy_file "$t" _diff_copy_cb > "$copy_out"
        if [ -s "$copy_out" ]; then
            echo "[copy.$t]"
            cat "$copy_out"
        fi
    done

    rm -rf "$DIFF_TMP_DIR"
    trap - EXIT
}

# links ファイル内の各コマンドの存在をチェックして結果を表示する
cmd_check() {
    awk '!/^[[:space:]]*(#|$)/ { print $1 }' "$DOTFILES_PATH/links.linux" "$DOTFILES_PATH/copy.linux" | sort -u | \
        while IFS= read -r cmd; do
            if exist_command "$cmd"; then
                echo "[ installed ] $cmd"
            else
                echo "[ not found ] $cmd"
            fi
        done

    if is_wsl; then
        awk '!/^[[:space:]]*(#|$)/ { print $1 }' "$DOTFILES_PATH/copy.windows" | sort -u | \
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
  clone                   リポジトリを ~/dotfiles へ clone する
  prepare                 必要なファイルを事前ダウンロード・生成する（WSL では wezterm フォントも取得）
  apply                   dotfiles を環境へ適用する（WSL 環境では Windows 側も対象）
  update                  dotfiles を更新する
  check                   各コマンドのインストール状況を確認する
  status                  dotfiles のリンク・同期状態を確認する
  diff                    未同期・衝突エントリの内容差分を表示する
  resolve <key>           同期のコンフリクトを解消した内容を、配置先とリポジトリ側の両方へ反映する
  resolve --delete <key>  削除と変更のコンフリクトを、配置先とリポジトリ側の両方から削除して解消する
  help                    この使い方を表示する
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
            resolve) cmd_resolve "$2" 0 ;;
            *)       usage >&2; exit 1 ;;
        esac
        ;;
    3)
        if [ "$1" = resolve ] && [ "$2" = --delete ]; then
            cmd_resolve "$3" 1
        else
            usage >&2; exit 1
        fi
        ;;
    *) usage >&2; exit 1 ;;
esac
