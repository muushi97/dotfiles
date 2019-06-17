#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

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
PS1=$PS1'\t \u \W]\$ '

export PATH=$PATH:~/alias/

export EDITOR=vim

export HISTCONTROL=ignoredups

xkbcomp -I$HOME/.xkb ~/.xkb/keymap/mykbd $DISPLAY 2> /dev/null

