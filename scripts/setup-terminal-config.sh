#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

STARSHIP_SRC="${REPO_ROOT}/starship/starship.toml"
ZSH_SNIPPET_SRC="${REPO_ROOT}/zsh/starship-init.zsh"
ITERM_PROFILE_SRC="${REPO_ROOT}/iterm2/dynamic-profiles/default-profile.json"
ITERM_PLIST_SRC="${REPO_ROOT}/iterm2/com.googlecode.iterm2.plist"

STARSHIP_DEST="${HOME}/.config/starship.toml"
ZSH_SNIPPET_DEST="${HOME}/.config/terminal-config/starship-init.zsh"
ZSHRC_DEST="${HOME}/.zshrc"
ITERM_PROFILE_DEST="${HOME}/Library/Application Support/iTerm2/DynamicProfiles/default-profile.json"
ITERM_PLIST_DEST="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"

APPLY_FULL_ITERM2=false
INSTALL_MISSING=false
SET_DEFAULT_ITERM_PROFILE=true
FORCE_DARK_MODE=false

usage() {
  cat <<'EOF'
Usage: ./scripts/setup-terminal-config.sh [--full-iterm2] [--install-missing] [--no-set-default-profile] [--dark-mode] [--help]

Options:
  --full-iterm2      Also apply full iTerm2 preferences plist (global app settings)
  --install-missing  Install missing dependencies (starship, iterm2) via Homebrew
  --no-set-default-profile  Do not set the imported iTerm2 profile as default
  --dark-mode        Force iTerm2 dark mode appearance by updating system prefs
  --help             Show this help text
EOF
}

backup_if_exists() {
  local file="$1"
  if [ -e "$file" ]; then
    cp -p "$file" "${file}.backup.${TIMESTAMP}"
    printf 'Backed up %s -> %s\n' "$file" "${file}.backup.${TIMESTAMP}"
  fi
}

set_iterm_default_profile() {
  local profile_guid
  local profile_name

  profile_guid="$(awk -F'\"' '/\"Guid\"[[:space:]]*:[[:space:]]*\"/ {print $4; exit}' "$ITERM_PROFILE_SRC")"
  profile_name="$(awk -F'\"' '/\"Name\"[[:space:]]*:[[:space:]]*\"/ {print $4; exit}' "$ITERM_PROFILE_SRC")"

  if [ -z "$profile_guid" ]; then
    printf 'Warning: could not find iTerm2 profile GUID in %s; skipping default profile update.\n' "$ITERM_PROFILE_SRC" >&2
    return 0
  fi

  mkdir -p "$(dirname "$ITERM_PLIST_DEST")"
  backup_if_exists "$ITERM_PLIST_DEST"

  if defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$profile_guid"; then
    if [ -n "$profile_name" ]; then
      printf 'Set iTerm2 default profile to %s (%s).\n' "$profile_name" "$profile_guid"
    else
      printf 'Set iTerm2 default profile GUID to %s.\n' "$profile_guid"
    fi
  else
    printf 'Warning: failed to set iTerm2 default profile GUID.\n' >&2
  fi
}

force_iterm_dark_mode() {
  printf 'Forcing iTerm2 dark mode appearance...\n'
  
  quit_iterm_if_running() {
    if pgrep -q iTerm; then
      printf 'Closing iTerm2...\n'
      osascript -e 'tell application "iTerm" to quit' 2>/dev/null || true
      sleep 1
    fi
  }
  
  quit_iterm_if_running
  
  defaults write com.googlecode.iterm2 "NSAppearance" -string "NSAppearanceNameDarkAqua"
  defaults write com.googlecode.iterm2 "UIPreferredContentSizeCategory" -string "L"
  
  printf 'Dark mode preferences set.\n'
  printf 'Restart iTerm2 to apply changes.\n'
}

for arg in "$@"; do
  case "$arg" in
    --full-iterm2)
      APPLY_FULL_ITERM2=true
      ;;
    --install-missing)
      INSTALL_MISSING=true
      ;;
    --no-set-default-profile)
      SET_DEFAULT_ITERM_PROFILE=false
      ;;
    --dark-mode)
      FORCE_DARK_MODE=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

install_missing_dependencies() {
  local missing_starship=false
  local missing_iterm=false

  if ! command -v starship >/dev/null 2>&1; then
    missing_starship=true
  fi
  if [ ! -d "/Applications/iTerm.app" ] && [ ! -d "/Applications/iTerm2.app" ]; then
    missing_iterm=true
  fi

  if [ "$missing_starship" = false ] && [ "$missing_iterm" = false ]; then
    return 0
  fi

  if ! command -v brew >/dev/null 2>&1; then
    printf 'Homebrew is required to auto-install missing dependencies.\n' >&2
    printf 'Install Homebrew from https://brew.sh/ and re-run.\n' >&2
    exit 1
  fi

  if [ "$missing_iterm" = true ]; then
    printf 'Installing iTerm2 via Homebrew cask...\n'
    brew install --cask iterm2
  fi

  if [ "$missing_starship" = true ]; then
    printf 'Installing Starship via Homebrew...\n'
    brew install starship
  fi
}

if [ "$INSTALL_MISSING" = true ]; then
  install_missing_dependencies
fi

for required_file in "$STARSHIP_SRC" "$ZSH_SNIPPET_SRC" "$ITERM_PROFILE_SRC"; do
  if [ ! -f "$required_file" ]; then
    printf 'Required file not found: %s\n' "$required_file" >&2
    exit 1
  fi
done

if [ "$APPLY_FULL_ITERM2" = true ] && [ ! -f "$ITERM_PLIST_SRC" ]; then
  printf 'Required file not found for --full-iterm2: %s\n' "$ITERM_PLIST_SRC" >&2
  exit 1
fi

printf 'Applying Starship config...\n'
mkdir -p "$(dirname "$STARSHIP_DEST")"
backup_if_exists "$STARSHIP_DEST"
cp "$STARSHIP_SRC" "$STARSHIP_DEST"

printf 'Installing Starship Zsh init snippet...\n'
mkdir -p "$(dirname "$ZSH_SNIPPET_DEST")"
backup_if_exists "$ZSH_SNIPPET_DEST"
cp "$ZSH_SNIPPET_SRC" "$ZSH_SNIPPET_DEST"

touch "$ZSHRC_DEST"
SOURCE_LINE='source "$HOME/.config/terminal-config/starship-init.zsh"'
if grep -Fq "$SOURCE_LINE" "$ZSHRC_DEST"; then
  printf 'Zsh source line already present in %s\n' "$ZSHRC_DEST"
else
  backup_if_exists "$ZSHRC_DEST"
  {
    printf '\n# terminal-config Starship init\n'
    printf '%s\n' "$SOURCE_LINE"
  } >> "$ZSHRC_DEST"
  printf 'Added Starship init source line to %s\n' "$ZSHRC_DEST"
fi

printf 'Installing iTerm2 dynamic profile...\n'
mkdir -p "$(dirname "$ITERM_PROFILE_DEST")"
backup_if_exists "$ITERM_PROFILE_DEST"
cp "$ITERM_PROFILE_SRC" "$ITERM_PROFILE_DEST"

if [ "$SET_DEFAULT_ITERM_PROFILE" = true ]; then
  set_iterm_default_profile
fi

if [ "$APPLY_FULL_ITERM2" = true ]; then
  printf 'Applying full iTerm2 preferences plist...\n'
  mkdir -p "$(dirname "$ITERM_PLIST_DEST")"
  backup_if_exists "$ITERM_PLIST_DEST"
  cp "$ITERM_PLIST_SRC" "$ITERM_PLIST_DEST"
fi

if [ "$FORCE_DARK_MODE" = true ]; then
  force_iterm_dark_mode
fi

if ! command -v starship >/dev/null 2>&1; then
  printf '\nWarning: starship is not installed. Install it with: brew install starship\n'
  printf 'Tip: run this script with --install-missing to install dependencies automatically.\n'
fi

printf '\nSetup complete.\n'
printf 'Next steps:\n'
printf '1) Restart iTerm2\n'
printf '2) Open a new shell (or run: exec zsh)\n'
if [ "$SET_DEFAULT_ITERM_PROFILE" = false ]; then
  printf '3) Open iTerm2 Settings -> Profiles and select/set the imported profile if needed\n'
fi
