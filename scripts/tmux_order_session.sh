#!/bin/bash

tmp_prefix="tmp_"

tmux list-sessions -F '#S' | while read -r session_name; do
    tmux rename-session -t "$session_name" "${tmp_prefix}${session_name}"
done

while IFS= read -r new_name; do
    original_name="${tmp_prefix}${new_name}"
    if tmux has-session -t "$original_name" 2>/dev/null; then
        tmux new-session -d -s "$new_name"
        
        tmux list-windows -t "$original_name" -F '#I' | while read -r window_index; do
            tmux move-window -s "${original_name}:${window_index}" -t "${new_name}:"
        done
        
        if [ $(tmux list-windows -t "$original_name" | wc -l) -eq 0 ]; then
            tmux kill-session -t "$original_name"
        fi
    else
        echo "${original_name} not found"
    fi
done < session_order.txt

echo "Done!"
