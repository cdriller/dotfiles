#!/bin/bash

TMUXP_DIR="${TMUXP_DIR:-$HOME/.config/tmuxp}"

sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

tmuxp_configs=$(find "$TMUXP_DIR" -maxdepth 1 -type f \( -name "*.yml" -o -name "*.yaml" \) -exec basename {} \; \
    | sed -E 's/\.(yml|yaml)$//' \
)

combined=$(printf "%s\n" "$tmuxp_configs" | sed 's/^/TMUXP:\t /' ; \
	   printf "%s\n" "$sessions" | sed 's/^/SESSION: /')

[ -z "$combined" ] && echo "No tmux sessions or tmuxp configs found." && exit 1

choice=$(printf "%s\n" "$sessions" | fzf --prompt="Choose session or tmuxp config > ")

[ -z "$choice" ] && exit 0

type=$(echo "$choice" | cut -d' ' -f1)
name=$(echo "$choice" | cut -d' ' -f2-)

if [ "$type" = "SESSION:" ]; then
 if [ -n "$TMUX" ]; then
        echo "You're inside tmux. Detaching so tmuxp won't nest..."
        tmux switch-client -t "$name"
    fi
    tmux attach -t "$name"
else
    tmuxp load "$name"
fi
