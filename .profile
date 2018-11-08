#!/bin/sh

# Profile file. Runs on login.

export PATH="$PATH:$HOME/.scripts"
export PYTHONPATH="$PYTHONPATH:$HOME/Documents/UlanMedia"
export EDITOR="vim"
export TERMINAL="urxvt"
export BROWSER="firefox"

[ -f ~/.bashrc ] && source ~/.bashrc

if [ "$(tty)" = "/dev/tty1" ]; then
	pgrep -x i3 || exec startx
fi

