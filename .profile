#!/usr/bin/env sh

export PATH="$PATH:$(du "$HOME/.scripts/" | cut -f2 | tr '\n' ':' | sed 's/:*$//'):$HOME/.local/bin"

export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/nvim
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/firefox
export READER=/usr/bin/zathura
export TRUEBROWSER="firefox"
export TERMINAL="st"
export FILE="ranger"
export XDG_CONFIG_HOME="$HOME/.config"
