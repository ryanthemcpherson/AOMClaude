# AOMClaude

Age of Mythology sound effects for Claude Code.

- **Waiting for input:** "Prostagma" — plays when Claude needs your attention (permission prompts, idle, questions)
- **Task complete:** Victory fanfare — plays when Claude finishes a response

Works on Windows, macOS, and Linux.

## Setup

```bash
git clone https://github.com/ryanthemcpherson/AOMClaude.git
cd AOMClaude
bash install.sh
```

Restart Claude Code after installing.

## Customization

Drop `.wav` files into `userinput/` to add more waiting sounds (one is picked at random). Replace `done/win.wav` to change the completion sound.
