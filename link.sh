#!/bin/bash

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
    FILES[config]=~/.ssh/config

    # termite
    MKDIRS+=~/.config/termite
    FILES[termite/config]=~/.config/termite/config

    # rofi
    MKDIRS+=~/.config/rofi
    FILES[rofi/config]=~/.config/rofi/config
    FILES[rofi/rofi-system.sh]=~/.config/rofi/rofi-system.sh

    # polybar
    MKDIRS+=~/.config/polbar
    FILES[polybar/config]=~/.config/polybar/config
    FILES[polybar/np.py]=~/.config/polybar/np.py
    FILES[polybar/polybar-restart]=~/.config/polybar/polybar-restart
    FILES[polybar/updates.sh]=~/.config/polybar/updates.sh

    # xkb
    MKDIRS+=~/.xkb/keymap
    MKDIRS+=~/.xkb/symbols
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
    FILES[my.cnf]=/etc/mysql/my.cnf

    # alias
    FILES[alias]=~/alias
}

function link () {
    for elem in ${MKDIRS[@]};
    do
        mkdir -p $elem
    done

    for KEY in ${!FILES[@]};
    do
        FILE=${FILES[$KEY]}

        if [[ -L $FILE ]]; then
            echo \"$FILE\" "is already exits. " \"$FILE\" "is simboricling."
        elif [[ -d $FILE ]]; then
            echo \"$FILE\" "is already exits. " \"$FILE\" "is directory"
        elif [[ -f $FILE ]]; then
            echo \"$FILE\" "is already exits. " \"$FILE\" "is file"
        else
            ln -i -sn $DOTFILES/$KEY $FILE
        fi
    done
}


# directories
PWD=`pwd`
DOTFILES=$(cd $(dirname $0); pwd)

# declaretions
declare -A FILES
declare -a MKDIRS

echo $1

if [[ "$1" = "install" ]]; then
    echo install start

    dotfiles
    link

    # clone vim plugins
    git clone https://github.com/lilydjwg/colorizer.git $VIMPLUGIN_DIR/colorizer/start/colorizer
    git clone https://github.com/scrooloose/nerdtree.git $VIMPLUGIN_DIR/nerdtree/start/nerdtree
    git clone https://github.com/cocopon/pgmnt.vim.git $VIMPLUGIN_DIR/pgmnt/start/pgmnt

    echo install finished


elif [[ "$1" = "update" ]]; then
    echo update start

    dotfiles
    link

    # pull vim plugins
    git -C $VIMPLUGIN_DIR/colorizer/start/colorizer pull
    git -C $VIMPLUGIN_DIR/nerdtree/start/nerdtree pull
    git -C $VIMPLUGIN_DIR/pgmnt/start/pgmnt pull

    echo update finished
fi

