#!/bin/bash

tmux kill-session -t scratchpad 2> /dev/null
urxvtc -name urxvt_scratchpad -e tmuxp load -y scratchpad
