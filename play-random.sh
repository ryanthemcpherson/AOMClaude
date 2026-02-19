#!/bin/bash
# Plays a random sound from the userinput directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FILES=()
for f in "$SCRIPT_DIR/userinput"/*.wav; do
  [ -f "$f" ] && FILES+=("$f")
done

if [ ${#FILES[@]} -gt 0 ]; then
  PICK="${FILES[$((RANDOM % ${#FILES[@]}))]}"
  bash "$SCRIPT_DIR/play-sound.sh" "$PICK"
fi
