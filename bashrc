#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto -l'
alias glog='git log --oneline --graph --decorate'
alias mkdir='mkdir -p'

# history にコマンドの実行日時を記録するようにする
HISTTIMEFORMAT='%Y-%m-%dT%T%z '

# PS1 に代入してプロンプト表示を変更
# \t=時間 \u=ユーザー名 \W カレントディレクトリ
PS1='['
# vim からサブシェルに入ったかわかるようにする
[[ -n "$VIMRUNTIME" ]] && \
	PS1=$PS1'vim '
# ranger からサブシェルに入ったかわかるようにする
[[ -n "$RANGER_LEVEL" ]] && \
	PS1=$PS1'ranger '
PS1=$PS1'\t \u \W] \$ '

# 出力のあとに改行をいれる
function add_line {
    if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
        PS1_NEWLINE_LOGIN=true
    else
        printf '\n'
    fi
}
PROMPT_COMMAND='add_line'

# alias
export PATH=$PATH:~/alias/

# sudoedit is vim
export EDITOR=vim

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups

xkbcomp -I$HOME/.xkb ~/.xkb/keymap/mykbd $DISPLAY 2> /dev/null

