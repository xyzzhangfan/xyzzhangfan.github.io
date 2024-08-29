---
layout:     post
title:      Installing tmux without root access
subtitle:   Tested on Ubuntu 20.04
date:       2021-03-13
author:     xyzzhangfan
header-img: img/post-bg-rwd.jpg
catalog: 	 true
tags:
  - Linux
  - bash
  - Tmux
---

## Installing tmux without root access

The following script  was adapted from [https://gist.github.com/ryin/3106801](https://gist.github.com/ryin/3106801)with some improvements and broken link fixes. Have tested on Ubuntu 20.04.

### Adding $HOME/local/bin to your PATH to use tmux.

``` sh

#!/bin/bash

# Script for installing tmux on systems where you don't have root access.

# tmux will be installed in $HOME/local/bin.

# It's assumed that wget and a C/C++ compiler are installed.

  

# exit on error

set -e

  

TMUX_VERSION=3.1b

  

# create our directories

mkdir -p $HOME/local $HOME/tmux_tmp

cd $HOME/tmux_tmp

  

# download source files for tmux, libevent, and ncurses

wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz

  

# extract files, configure, and compile

  

############

# libevent #

############

tar xvzf libevent-2.0.19-stable.tar.gz

cd libevent-2.0.19-stable

./configure --prefix=$HOME/local --disable-shared

make -j
make install 

############
cd ..

  

############

# ncurses  #

############

tar xvzf ncurses-6.2.tar.gz

cd ncurses-6.2

./configure --prefix=$HOME/local

make -j
make install  
############

cd ..

  

############

# tmux #

############

tar xvzf tmux-${TMUX_VERSION}.tar.gz

cd tmux-${TMUX_VERSION}

#./autogen.sh

./configure CFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-L$HOME/local/lib -L$HOME/local/include/ncurses -L$HOME/local/include"

CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make

cp tmux $HOME/local/bin

cd ..

  

# cleanup

rm -rf $HOME/tmux_tmp

  

echo  "$HOME/local/bin/tmux is now available. You can optionally add $HOME/local/bin to your PATH."
```
