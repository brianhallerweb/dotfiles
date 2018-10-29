#!/bin/sh

# Runs on login.

# I don't know what these 2 do
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

export PATH="${PATH}:/home/bsh/Bin"
export PYTHONPATH="${PYTHONPATH}:/home/bsh/Documents/UlanMedia"
export EDITOR=/usr/bin/vim
export BROWSER=/usr/bin/firefox


[ -f ~/.bashrc ] && source ~/.bashrc

