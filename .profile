#!/bin/sh

# This script will be executed by greetd on login.

# Append "$1" to $PATH when not already in.
# This function was taken from /etc/profile
append_path() {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

prepend_path() {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="$1${PATH:+$PATH:}"
    esac
}

append_path "$HOME/.local/bin"
append_path "$HOME/.local/share/gem/ruby/3.0.0/bin"
append_path "$HOME/.local/share/go/bin/"
prepend_path "$CARGO_HOME/bin"

unset -f append_path
unset -f prepend_path

#
# XDG Base Directory
#

# User directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# System directories
export XDG_DATA_DIRS="/usr/local/share:/usr/share:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share"
export XDG_CONFIG_DIRS="/etc/xdg"

#
# Program specific
#

export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="chromium"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Dark theme (https://wiki.archlinux.org/title/Dark_mode_switching)
export GTK_THEME="Adwaita:dark"
export GTK2_RC_FILES="/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc"
export QT_STYLE_OVERRIDE="adwaita-dark"

# Clean up $HOME

# shell
export HISTFILE="$XDG_DATA_HOME/history"

# Rustup + Cargo
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# gforth
export GFORTHHIST="$XDG_DATA_HOME/gforth-history"

# Go
export GOPATH="$XDG_DATA_HOME/go"

# TeX Live
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"

# Julia
export JULIA_DEPOT_PATH="$XDG_DATA_HOME/julia:$JULIA_DEPOT_PATH"

# Puts '.python_history' somewhere else
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/startup.py"

export ANDROID_HOME="$XDG_DATA_HOME/android"

export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

