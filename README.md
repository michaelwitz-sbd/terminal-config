# terminal-config
Reusable terminal appearance configuration for macOS laptops.

This repo contains:
- `starship/starship.toml` — prompt configuration copied from this machine
- `zsh/starship-init.zsh` — safe Zsh snippet to initialize Starship
- `iterm2/dynamic-profiles/default-profile.json` — iTerm2 profile export (dynamic profile format)
- `iterm2/com.googlecode.iterm2.plist` — full iTerm2 preferences export (optional full restore)
- `scripts/setup-terminal-config.sh` — one-command installer for Starship + iTerm2 profile
- `TERMINAL_SETUP.md` — detailed setup instructions

Required software on target machine:
- Homebrew
- iTerm2
- Starship

The setup script supports optional dependency installation:
- `./scripts/setup-terminal-config.sh --install-missing`
