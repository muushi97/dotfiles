#!/bin/bash

# directories
PWD=`pwd`
DOTFILES=$(cd $(dirname $0); pwd)

# declaretions
declare -A FILES

function dotfiles () {
    # x window
    FILES[xinitrc]=~/.xinitrc
    FILES[xprofile]=~/.xprofile

    # xmonad
    FILES[xmonad.hs]=~/.xmonad/xmonad.hs
    FILES[xmobarrc.hs]=~/.xmonad/xmobarrc

    # bash
    FILES[bashrc]=~/.bashrc

    # urxvt
    FILES[Xdefaults]=~/.Xdefaults

    # git
    FILES[gitconfig]=~/.gitconfig

    # ssh
    FILES[ssh/config]=~/.ssh/config

    # termite
    FILES[termite/config]=~/.config/termite/config

    # ranger
    FILES[ranger/rc.conf]=~/.config/ranger/rc.conf
    FILES[ranger/rifle.conf]=~/.config/ranger/rifle.conf
    FILES[ranger/scope.sh]=~/.config/ranger/scope.sh

    # rofi
    FILES[rofi/config]=~/.config/rofi/config
    FILES[rofi/rofi-system.sh]=~/.config/rofi/rofi-system.sh

    # polybar
    FILES[polybar/config]=~/.config/polybar/config
    FILES[polybar/np.py]=~/.config/polybar/np.py
    FILES[polybar/polybar-restart]=~/.config/polybar/polybar-restart
    FILES[polybar/updates.sh]=~/.config/polybar/updates.sh
    FILES[polybar/launch.sh]=~/.config/polybar/launch.sh

    # xkb
    FILES[xkb/keymap/mykbd]=~/.xkb/keymap/mykbd
    FILES[xkb/symbols/myswap]=~/.xkb/symbols/myswap

    # 
    FILES[redshift.conf]=~/.config/redshift.conf

    # nitrogen
    FILES[nitrogen]=~/.config

    # xscreensaver
    FILES[xscreensaver]=~/.xscreensaver

    # vim
    VIMPLUGIN_DIR=~/.vim/pack
    FILES[vimrc]=~/.vimrc
    FILES[vim/colors]=~/.vim/colors
    FILES[vim/ftdetect]=~/.vim/ftdetect
    FILES[vim/ftplugin]=~/.vim/ftplugin

    # tmux
    FILES[tmux.conf]=~/.tmux.conf

    # mysql
    #FILES[my.cnf]=/etc/mysql/my.cnf

    # my scripts
    FILES[bin]=~/bin

    # keymap
    FILES[Xmodmap]=~/.Xmodmap

    # dunst
    FILES[dunstrc]=~/.config/dunst/dunstrc
}

function link () {
    for KEY in ${!FILES[@]};
    do
        FILE=${FILES[$KEY]}

        if [[ -L $FILE ]]; then
            echo \"$FILE\" "is already exits. " \"$FILE\" "is simboriclink."
        elif [[ -d $FILE ]]; then
            echo \"$FILE\" "is already exits. " \"$FILE\" "is directory"
        elif [[ -f $FILE ]]; then
            echo \"$FILE\" "is already exits. " \"$FILE\" "is file"
        else
            mkdir -p $(dirname $FILE)
            ln -i -sn $DOTFILES/$KEY $FILE
        fi
    done
}


if [[ "$1" = "install" ]]; then
    echo install start

    dotfiles
    link

    # clone vim plugins
    git clone https://github.com/lilydjwg/colorizer.git $VIMPLUGIN_DIR/colorizer/start/colorizer
    git clone https://github.com/scrooloose/nerdtree.git $VIMPLUGIN_DIR/nerdtree/start/nerdtree
    git clone https://github.com/cocopon/pgmnt.vim.git $VIMPLUGIN_DIR/pgmnt/start/pgmnt

    # git prompt
    GIT_VERSION="2.5.0"
    curl https://raw.githubusercontent.com/git/git/v${GIT_VERSION}/contrib/completion/git-completion.bash > ~/.git-completion.bash
    curl https://raw.githubusercontent.com/git/git/v${GIT_VERSION}/contrib/completion/git-prompt.sh > ~/.git-prompt.sh

    echo install finished


elif [[ "$1" = "update" ]]; then
    echo update start

    dotfiles
    link

    # pull vim plugins
    git -C $VIMPLUGIN_DIR/colorizer/start/colorizer pull --rebase
    git -C $VIMPLUGIN_DIR/nerdtree/start/nerdtree pull --rebase
    git -C $VIMPLUGIN_DIR/pgmnt/start/pgmnt pull --rebase

    echo update finished
fi

