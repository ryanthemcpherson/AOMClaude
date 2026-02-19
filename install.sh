#!/bin/bash
# Installs Claude Code hooks for AOM sound notifications
# Run after cloning to set up hooks on any platform
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get platform-appropriate absolute path for hook commands
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*|*_NT*)
    HOOK_DIR=$(cygpath -m "$SCRIPT_DIR")
    ;;
  *)
    HOOK_DIR="$SCRIPT_DIR"
    ;;
esac

SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Use node (guaranteed available since Claude Code requires it)
SETTINGS_FILE="$SETTINGS_FILE" HOOK_DIR="$HOOK_DIR" node -e "
const fs = require('fs');
const settingsPath = process.env.SETTINGS_FILE;
const dir = process.env.HOOK_DIR;

const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
if (!settings.hooks) settings.hooks = {};

const playRandom = 'bash ' + dir + '/play-random.sh';
const playDone = 'bash ' + dir + '/play-done.sh';
const hookOpts = { async: true, timeout: 10 };

settings.hooks.Notification = [
  { matcher: 'permission_prompt', hooks: [{ type: 'command', command: playRandom, ...hookOpts }] },
  { matcher: 'elicitation_dialog', hooks: [{ type: 'command', command: playRandom, ...hookOpts }] }
];

settings.hooks.Stop = [
  { hooks: [{ type: 'command', command: playDone, ...hookOpts }] }
];

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');

console.log('Hooks installed successfully!');
console.log('');
console.log('  User input sounds (userinput/*.wav) play when:');
console.log('    - Claude needs tool permission');
console.log('    - Claude asks you a question');
console.log('');
console.log('  Completion sound (done/win.wav) plays when:');
console.log('    - Claude finishes a response');
console.log('');
console.log('Restart Claude Code for hooks to take effect.');
"
