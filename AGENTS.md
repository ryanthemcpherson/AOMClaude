# AGENTS.md

## Purpose

AOMClaude installs Age of Mythology sound effects as Claude Code hook notifications. A
"Prostagma" clip plays when Claude Code needs user attention (permission prompts,
elicitation dialogs) and a victory sound plays when Claude finishes a response. The whole
project is a handful of Bash scripts plus `.wav` assets; there is no application to build
or deploy.

## Tech stack

- Bash scripts (POSIX-ish, but written for `bash` — `play-random.sh` uses arrays and `$RANDOM`).
- Node.js, used only inside `install.sh` as a one-shot `node -e` script to edit JSON settings.
  Node is assumed present because Claude Code requires it.
- Platform audio backends: `afplay` (macOS), PowerShell `System.Windows.Media.MediaPlayer`
  (Windows via MINGW/MSYS/Cygwin), `paplay` then `aplay` (Linux).

## Layout and entry points

- `install.sh` — the only entry point users run. Resolves its own directory, converts it with
  `cygpath -m` on Windows shells, and merges `hooks.Notification` (matchers
  `permission_prompt`, `elicitation_dialog`) and `hooks.Stop` entries into
  `~/.claude/settings.json`, creating the file as `{}` if missing.
- `play-sound.sh` — cross-platform player. `play-sound.sh <file.wav> [volume]`, volume
  `0.0`–`1.0`, default `0.3`. Exits 1 if the file argument is missing or not a file.
- `play-random.sh` — picks one random `.wav` from `userinput/` and delegates to `play-sound.sh`.
  Wired to the Notification hooks.
- `play-done.sh` — plays `done/win.wav` via `play-sound.sh`. Wired to the Stop hook.
- `userinput/*.wav` — attention sounds (currently `gvms4.wav`, `gvfs4.wav`); any `.wav`
  dropped here joins the random pool.
- `done/win.wav` — completion sound; replace the file to change it.

## Build / run / test

There is no build step, package manager, or test suite.

- Install: `bash install.sh` (then restart Claude Code for hooks to take effect).
- Manually exercise a sound: `bash play-random.sh`, `bash play-done.sh`, or
  `bash play-sound.sh done/win.wav 0.5`.
- Syntax check after edits: `bash -n *.sh`.
- Verify the install result by inspecting `~/.claude/settings.json` — note that this file is
  outside the repo and `install.sh` rewrites the `Notification` and `Stop` hook arrays
  wholesale, preserving other keys.

## Conventions

- Scripts are invoked as `bash <script>`; they are not executable bits in git and have no
  shebang dependency at call time, so keep `bash foo.sh` invocation style rather than adding
  `./foo.sh` to docs or hooks.
- Every script resolves its own location with
  `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"` and builds absolute paths from it. Hooks run
  from arbitrary working directories, so never use relative paths.
- Handle all four platform branches in the `case "$(uname -s)"` blocks
  (`Darwin`, `MINGW*|MSYS*|CYGWIN*|*_NT*`, `Linux`) when touching playback or path logic.
- Keep playback failure silent and non-fatal: hooks are registered with
  `{ async: true, timeout: 10 }` and missing audio tools must not error out a Claude Code turn.
- Do not add a `Notification` matcher for idle prompts — `idle_prompt` was deliberately removed
  (commit 2ea990e) because it double-fired with the Stop hook.
- `.gitignore` excludes `.claude/`; keep local Claude settings out of the repo.
- Audio assets are `.wav` only — the players pass files straight to backends that assume WAV.
