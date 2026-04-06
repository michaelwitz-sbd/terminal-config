# terminal-config
Reusable terminal appearance configuration for macOS laptops.

This repo contains:
- `starship/starship.toml` — prompt configuration copied from this machine
- `zsh/starship-init.zsh` — safe Zsh snippet to initialize Starship
- `iterm2/dynamic-profiles/default-profile.json` — iTerm2 profile export (dynamic profile format)
- `iterm2/com.googlecode.iterm2.plist` — full iTerm2 preferences export (optional full restore)
- `scripts/setup-terminal-config.sh` — one-command installer for Starship + iTerm2 profile
- `TERMINAL_SETUP.md` — detailed setup instructions

The setup script installs config files, updates `~/.zshrc` to source the Starship snippet, sets the imported iTerm2 profile as default, and creates timestamped backups before replacing existing files.
Default iTerm2 terminal size in this repo: `120` columns x `30` rows.
For full effect on a target machine:
- iTerm2
- Starship

Homebrew is only required if you want the script to auto-install missing dependencies:
- `./scripts/setup-terminal-config.sh --install-missing`

Useful setup options:
- `./scripts/setup-terminal-config.sh --full-iterm2` (also restore global iTerm2 app preferences)
- `./scripts/setup-terminal-config.sh --no-set-default-profile` (opt out of auto-setting the imported profile as default)

## Zsh quick start (copy/paste)
Run these commands in your terminal:

```bash
cd ~/Dev/terminal-config
git pull
./scripts/setup-terminal-config.sh
```

Then quit and re-open iTerm2.

Important:
- Run the script as `./scripts/setup-terminal-config.sh`
- Do not run `source scripts/setup-terminal-config.sh`

Why:
- `./...` runs the script in its own Bash process (as intended by `#!/usr/bin/env bash`)
- `source ...` executes script commands in your current shell session, which can cause unexpected side effects
