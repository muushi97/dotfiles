#!/bin/bash

# マウント用

# 基本使用用 (文字コードのせいで色々あるから場合によって使い分け)
#sudo mount -t auto -o rw,relatime,uid=$(id -u),gid=$(id -g),codepage=932,iocharset=utf8,umask=0077 $1 $2
# sudo mount -t auto -o rw,relatime,uid=$(id -u),gid=$(id -g),iocharset=utf8,umask=0077 $1 $2

# NTFS フォーマット用のコマンド (一つしか試してないけど -t auto じゃ何故か駄目たった)
# ntfs-3g パッケージをインストールしないと駄目かも (未インストール時の動作は確認してないからわからないゾ)

# ntfs フォーマット用
#sudo mount -t ntfs -o rw,relatime,uid=$(id -u),gid=$(id -g),iocharset=utf8,umask=0077 $1 $2

# USB のやつ
sudo mount -t auto -o rw,relatime,uid=$(id -u),gid=$(id -g),codepage=932,iocharset=utf8,umask=0077 $1 $2
#sudo mount -t vfat -o rw,relatime,uid=$(id -u),gid=$(id -g),codepage=932,iocharset=utf8,umask=0077 $1 $2

