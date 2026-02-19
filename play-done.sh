#!/bin/bash
# Plays the task completion sound
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/play-sound.sh" "$SCRIPT_DIR/done/win.wav"
