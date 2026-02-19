#!/bin/bash
# Cross-platform sound player for Claude Code hooks
# Usage: play-sound.sh <file.wav> [volume]
# Volume: 0.0 (silent) to 1.0 (full), default 0.3

FILE="$1"
VOLUME="${2:-0.3}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    afplay -v "$VOLUME" "$FILE"
    ;;
  MINGW*|MSYS*|CYGWIN*|*_NT*)
    FILE=$(cygpath -m "$FILE")
    powershell.exe -NoProfile -Command "
      Add-Type -AssemblyName PresentationCore
      \$p = New-Object System.Windows.Media.MediaPlayer
      \$p.Volume = $VOLUME
      \$p.Open([Uri]::new('file:///$FILE'))
      \$p.Play()
      Start-Sleep -Seconds 3
    "
    ;;
  Linux)
    if command -v paplay &>/dev/null; then
      VOL=$(awk "BEGIN {printf \"%.0f\", $VOLUME * 65536}")
      paplay --volume="$VOL" "$FILE"
    elif command -v aplay &>/dev/null; then
      aplay -q "$FILE"
    fi
    ;;
esac
