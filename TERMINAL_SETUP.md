# Terminal setup guide (iTerm2 + Starship)
This document explains how to reproduce the terminal look-and-feel from this machine on another Mac.

## What is included
- Starship prompt config: `starship/starship.toml`
- iTerm2 profile (colors/fonts/profile behavior): `iterm2/dynamic-profiles/default-profile.json`
- Full iTerm2 preferences backup: `iterm2/com.googlecode.iterm2.plist`
- Safe Zsh Starship init snippet: `zsh/starship-init.zsh`

## Profile details captured from this machine
- iTerm2 profile name: `Default`
- Exported profiles count: `1`
- Default terminal size: `120` columns x `30` rows
- Primary font: `CourierNewPSMT 18`
- Non-ASCII font fallback: `Monaco 12`
- Bright bold text enabled: `true`
- Light mode background is near-white (RGB approximately `0.98, 0.98, 0.98`)
- Dark mode background is near-black with light gray text (RGB approximately `0.08, 0.10, 0.12` background and `0.86, 0.86, 0.86` foreground)
- Supports system appearance switching (light/dark mode toggle)

## Prerequisites
- macOS
- Zsh shell
- iTerm2 (recommended)
- Starship (recommended)

## Install required applications first
If Homebrew is not installed yet and you want to install dependencies via command line, install it first using the official instructions:
- https://brew.sh/

Then install required apps:
- `brew install --cask iterm2`
- `brew install starship`

## Quick start (recommended)
1. Clone this repo:
   - `git clone https://github.com/michaelwitz/terminal-config.git`
2. Run the setup script:
   - `cd terminal-config`
   - `./scripts/setup-terminal-config.sh`
3. Restart iTerm2 and open a new tab/shell.
4. The script will copy configs, install `~/.config/terminal-config/starship-init.zsh`, ensure `~/.zshrc` sources it, and set the imported iTerm2 profile as default.

### Zsh users: explicit copy/paste
```bash
cd ~/Dev/terminal-config
git pull
./scripts/setup-terminal-config.sh
```

Do not run `source scripts/setup-terminal-config.sh`.

Reason:
- `./scripts/setup-terminal-config.sh` runs the installer in a separate Bash process (intended behavior).
- `source scripts/setup-terminal-config.sh` runs it inside your current interactive shell, which can leak side effects into your live session.

### Force dark mode appearance (optional)
If you want the terminal to use dark mode colors even if your system appearance is set to light:
```bash
./scripts/setup-terminal-config.sh --dark-mode
```

Optional full iTerm2 preferences restore (includes app-level/global settings):
- `./scripts/setup-terminal-config.sh --full-iterm2`
Optional dependency auto-install (if Homebrew already exists):
- `./scripts/setup-terminal-config.sh --install-missing`
Optional: skip automatic default-profile selection:
- `./scripts/setup-terminal-config.sh --no-set-default-profile`

## Recommended setup (profile + prompt, minimal risk)
If you use the script above, you can skip this section. These are the equivalent manual steps.
1. Clone this repo:
   - `git clone https://github.com/michaelwitz/terminal-config.git`
2. Install Starship:
   - `brew install starship`
3. Install Starship config:
   - `mkdir -p ~/.config`
   - `cp terminal-config/starship/starship.toml ~/.config/starship.toml`
4. Enable Starship in Zsh:
   - Back up existing shell config first:
     - `cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)`
   - Add this line to the end of `~/.zshrc`:
     - `source /ABSOLUTE/PATH/TO/terminal-config/zsh/starship-init.zsh`
5. Install iTerm2 dynamic profile:
   - `mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"`
   - `cp terminal-config/iterm2/dynamic-profiles/default-profile.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/default-profile.json"`
6. Restart iTerm2.
7. In iTerm2:
   - Open Settings → Profiles
   - Select the imported profile (`Default`)
   - Set it as default profile if needed

## Optional full iTerm2 restore (includes global app preferences)
Use this only if you want broad iTerm2 behavior to match this machine, not just profile appearance.

1. Quit iTerm2 completely.
2. Back up current preferences:
   - `cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.backup.$(date +%Y%m%d%H%M%S)`
3. Apply exported prefs:
   - `cp terminal-config/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist`
4. Re-open iTerm2.

## Troubleshooting: iTerm2 Dark Mode Not Working

### Problem: Terminal stays in light mode even after changing to dark mode
The profile includes both light and dark color schemes, but iTerm2 doesn't automatically respect system appearance changes by default.

### Solutions (try in order):

**Solution 1: Use the setup script with --dark-mode flag**
```bash
./scripts/setup-terminal-config.sh --dark-mode
```
Then quit and restart iTerm2.

**Solution 2: Manually set appearance in iTerm2 Settings**
1. Open iTerm2 Preferences (Cmd + ,)
2. Go to Appearance tab
3. Under "General":
   - Set "Theme" to your preferred appearance
   - Try: "Dark", "Light", or "Auto" (system-dependent)
4. Under "Profiles" → "Colors":
   - Select the "Default" profile
   - Verify "Use Separate Colors for Light and Dark Mode" is enabled
5. Close and reopen iTerm2

**Solution 3: Check system appearance setting**
macOS controls the system appearance. iTerm2 should follow your system preference:
- System Preferences → General → Appearance
- Choose "Light", "Dark", or "Auto"

**Solution 4: Full preferences reset**
If none of the above work, restore full iTerm2 preferences:
```bash
./scripts/setup-terminal-config.sh --full-iterm2
```

## Exact iTerm2 match across machines
For closest match with minimal manual steps:
- Run `./scripts/setup-terminal-config.sh` to install the profile and auto-set it as default.
- Restart iTerm2 so profile/default changes are fully loaded.
- If you also want global iTerm2 app preferences to match, run `./scripts/setup-terminal-config.sh --full-iterm2`.

## Verification checklist
- Prompt shows two lines with directory on top and `❯` on the bottom.
- Git branch/status segments appear in Git repos.
- Python and Node segments appear only when relevant.
- Colors and font match expected appearance.
- New terminal sessions open at approximately `120x30` (unless later overridden by local iTerm2 window/layout behavior).

## Notes
- This repo intentionally avoids copying secrets from shell startup files.
- If your target machine does not have the same font, iTerm2 may fall back to another font and look slightly different.
- If `~/.zshrc` already has Starship init lines, keep only one initialization block.
- The setup script creates timestamped backups before changing existing `~/.config/starship.toml`, `~/.config/terminal-config/starship-init.zsh`, iTerm2 profile files, `~/Library/Preferences/com.googlecode.iterm2.plist`, and `~/.zshrc`.
- Without `--install-missing`, the setup script does not install dependencies; it only configures files.

## Refresh this repo after local changes
From this source machine, run:
- `cp ~/.config/starship.toml /PATH/TO/terminal-config/starship/starship.toml`
- `plutil -convert xml1 -o /PATH/TO/terminal-config/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist`
- `python3 - <<'PY'\nimport plistlib, json\nsrc = '/Users/michael/Library/Preferences/com.googlecode.iterm2.plist'\nout = '/PATH/TO/terminal-config/iterm2/dynamic-profiles/default-profile.json'\nwith open(src, 'rb') as f:\n    data = plistlib.load(f)\nwith open(out, 'w', encoding='utf-8') as f:\n    json.dump({'Profiles': data.get('New Bookmarks', [])}, f, indent=2)\n    f.write('\\n')\nPY`
