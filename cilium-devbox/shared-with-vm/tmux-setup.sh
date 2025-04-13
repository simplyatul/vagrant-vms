#!/bin/sh

SESSION="s1"
SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

WINDOW_1="w1"
WINDOW_2="w2"
WINDOW_3="w3"
PANE_0=0
PANE_1=1

if [ "$SESSIONEXISTS" = "" ]
then
	tmux new-session -d -s $SESSION
	# Newly created session has only single Window
        # It is identified as 0
	tmux rename-window -t $SESSION:0 $WINDOW_1
	tmux splitw -v -t $SESSION:$WINDOW_1
	tmux new-window -t $SESSION -n $WINDOW_2
	tmux new-window -t $SESSION -n $WINDOW_3
fi

tmux attach-session -t $SESSION:$WINDOW_1.$PANE_0

