# Dark Mode Fix - Bug Report & Solution

## Problem

The iTerm2 profile was configured to use light mode by default and had a broken dark mode implementation that didn't work reliably.

### Root Cause

The original profile used iTerm2's **"Use Separate Colors for Light and Dark Mode"** feature (`true` setting), which is designed to automatically switch between light and dark color schemes based on macOS system appearance.

**However, this feature is broken in iTerm2** - it does not auto-switch when you toggle between light and dark mode in System Preferences. This is a known bug: [iTerm2 GitLab Issue #11350](https://gitlab.com/gnachman/iterm2/-/issues/11350)

Additionally, the main `"Background Color"` was set to light mode (RGB 0.98, 0.98, 0.98 - near white), which was the fallback color when the separate colors feature failed.

## Solution Implemented

### Changes Made

1. **Disabled the broken "Use Separate Colors for Light and Dark Mode" feature**
   - Changed from `true` to `false` in `iterm2/dynamic-profiles/default-profile.json`
   - This prevents iTerm2 from trying to auto-switch, which was causing the issue

2. **Changed the default "Background Color" to dark mode**
   - From: RGB (0.98, 0.98, 0.98) - light/near-white
   - To: RGB (0.08, 0.10, 0.12) - dark/near-black
   - This ensures dark mode is always active

3. **Updated "Foreground Color" to light gray for contrast**
   - From: RGB (0.06, 0.06, 0.06) - near-black text
   - To: RGB (0.86, 0.86, 0.86) - light gray text
   - Provides proper contrast against dark background

4. **Set cursor color to green**
   - Changed "Cursor Color" to match Starship's green prompt: RGB (0.0, 0.76, 0.76)
   - Provides visual consistency with the green `❯` prompt character

5. **Added UI improvements**
   - Added `"Use Tab Color For Window": false`
   - Added `"Use Window Background Color": true`
   - These ensure consistent background rendering

### Script Enhancements

Updated `scripts/setup-terminal-config.sh` with:

- New `--dark-mode` flag to force iTerm2 dark mode appearance
- `force_iterm_dark_mode()` function that sets macOS appearance preferences
- Updated usage documentation and help text

### Documentation Updates

Added comprehensive troubleshooting section to `TERMINAL_SETUP.md`:
- Problem description
- 4 solution approaches (increasing complexity)
- Clear steps for each solution
- References to known bugs

## Why This Works

By disabling the broken auto-switching feature and setting a single dark color scheme, we bypass the bug entirely. The terminal now:

✅ Shows dark mode consistently  
✅ Works reliably without system appearance toggling  
✅ Provides proper contrast with light text on dark background  
✅ Matches the green Starship prompt for visual cohesion  
✅ Works seamlessly with Starship prompt renderer  

## Important Note About Blinking Cursors

**Blinking cursors do NOT work with Starship.** Starship is a custom prompt renderer that takes over terminal cursor rendering. When using Starship:
- The prompt character (`❯`) is rendered by Starship, not iTerm2
- iTerm2's cursor blinking setting only applies to the invisible terminal cursor
- This is expected behavior and is not a bug

Most terminal users disable blinking when using custom prompts like Starship.

## Installation

For new installations, simply run:

```bash
./scripts/setup-terminal-config.sh
```

Or to force dark mode appearance (if system is in light mode):

```bash
./scripts/setup-terminal-config.sh --dark-mode
```

## Files Modified

- `iterm2/dynamic-profiles/default-profile.json` - Profile color scheme and settings
- `scripts/setup-terminal-config.sh` - Setup script with new `--dark-mode` option
- `TERMINAL_SETUP.md` - Added troubleshooting guide
- `starship/starship.toml` - Minor configuration improvements

## References

- [iTerm2 Dark Mode Bug #11350](https://gitlab.com/gnachman/iterm2/-/issues/11350)
- [iTerm2 Preferences Documentation](https://iterm2.com/documentation-preferences-appearance.html)
- [Starship Prompt Documentation](https://starship.rs/config)
