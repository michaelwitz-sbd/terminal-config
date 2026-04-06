# Starship prompt initialization for Zsh
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
