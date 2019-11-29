#!/bin/bash

# x window
ln -i -sn ~/dotfiles/xinitrc ~/.xinitrc
ln -i -sn ~/dotfiles/xprofile ~/.xprofile

# xmonad
ln -i -sn ~/dotfiles/xmonad.hs ~/.xmonad/xmonad.hs
ln -i -sn ~/dotfiles/xmobarrc.hs ~/.xmonad/xmobarrc

# bash
ln -i -sn ~/dotfiles/bashrc ~/.bashrc

# urxvt
ln -i -sn ~/dotfiles/Xdefaults ~/.Xdefaults

# git
ln -i -sn ~/dotfiles/gitconfig ~/.gitconfig

# ssh
ln -i -sn ~/dotfiles/ssh/config ~/.ssh/config

# termite
mkdir ~/.config/termite
ln -i -sn ~/dotfiles/termite/config ~/.config/termite/config

# rofi
mkdir ~/.config/rofi
ln -i -sn ~/dotfiles/rofi/config ~/.config/rofi/config
ln -i -sn ~/dotfiles/rofi/rofi-system.sh ~/.config/rofi/rofi-system.sh

# polybar
mkdir ~/.config/polbar
ln -i -sn ~/dotfiles/polybar/config ~/.config/polybar/config
ln -i -sn ~/dotfiles/polybar/np.py ~/.config/polybar/np.py
ln -i -sn ~/dotfiles/polybar/polybar-restart ~/.config/polybar/polybar-restart
ln -i -sn ~/dotfiles/polybar/updates.sh ~/.config/polybar/updates.sh

# xkb
mkdir ~/.xkb
mkdir ~/.xkb/keymap ~/.xkb/symbols
ln -i -sn ~/dotfiles/xkb/keymap/mykbd ~/.xkb/keymap/mykbd
ln -i -sn ~/dotfiles/xkb/symbols/myswap ~/.xkb/symbols/myswap

# ???
ln -i -sn ~/dotfiles/redshift.conf ~/.config/redshift.conf

# nitrogen
ln -i -sn ~/dotfiles/nitrogen ~/.config

# xscreensaver
ln -i -sn ~/dotfiles/xscreensaver ~/.xscreensaver

# vim
ln -i -sn ~/dotfiles/vimrc ~/.vimrc
ln -i -sn ~/dotfiles/vim/colors ~/.vim/colors
ln -i -sn ~/dotfiles/vim/pack ~/.vim/pack
ln -i -sn ~/dotfiles/vim/ftdetect ~/.vim/ftdetect
ln -i -sn ~/dotfiles/vim/ftplugin ~/.vim/ftplugin

# tmux
ln -i -sn ~/dotfiles/tmux.conf ~/.tmux.conf

# mysql
sudo ln -i -sn ~/dotfiles/my.cnf /etc/mysql/my.cnf

# alias
ln -i -sn ~/dotfiles/alias ~/alias


