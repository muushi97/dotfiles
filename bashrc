#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#alias glog='git log --oneline --graph --decorate'
#alias mkdir='mkdir -p'
#alias mv='mv -i'
#alias cp='cp -i'

# history にコマンドの実行日時を記録するようにする
HISTTIMEFORMAT='%Y-%m-%dT%T%z '

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# プロンプトで __git_ps1 を使うためにスクリプトを読込む
[[ -f /usr/lib/git-core/git-sh-prompt ]] && . /usr/lib/git-core/git-sh-prompt

# PS1 に代入してプロンプト表示を変更
# \t=時間 \u=ユーザー名 \W=カレントディレクトリ
# git 用
GIT_PS1_SHOWDIRTYSTATE=true      # *:unstaged, +:staged
GIT_PS1_SHOWUNTRACKEDFILES=true  # %:untracked
GIT_PS1_SHOWSTASHSTATE=true      # $:stashed
GIT_PS1_SHOWUPSTREAM=auto        # >:ahead, <:behind
GIT_PS1_SHOWCOLORHINTS=true      # 状態を色分けする (PROMPT_COMMAND から __git_ps1 を呼ぶ必要がある)

# Gentoo の配色にする: user@host は緑 (root は赤)、ディレクトリから $ までは青
if ((EUID == 0)); then
	PS1_USERHOST='\[\e[01;31m\]\u@\h\[\e[00m\]'
else
	PS1_USERHOST='\[\e[01;32m\]\u@\h\[\e[00m\]'
fi
# __git_ps1 が、この 2 つの間に git の状態を挟んで PS1 を組み立てる
# git の状態と、vim から入ったサブシェルかどうかを後ろに付ける
PS1_PRE='['"$PS1_USERHOST"'\[\e[01;34m\] \W]\[\e[00m\]'
PS1_POST='${VIMRUNTIME:+[\[\e[36m\]vim\[\e[00m\]]}\[\e[01;34m\]\$\[\e[00m\] '

# 出力のあとに改行をいれる
function add_line {
    if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
        PS1_NEWLINE_LOGIN=true
    else
        printf '\n'
    fi
}
PROMPT_COMMAND=(add_line '__git_ps1 "$PS1_PRE" "$PS1_POST" "[%s]"')

# alias
export PATH=$PATH:~/bin/
export PATH=$PATH:~/.local/bin

# sudoedit is vim
export EDITOR=vim

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
