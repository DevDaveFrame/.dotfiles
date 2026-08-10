# dotfiles

## Setup

```bash
git clone https://github.com/daveframe/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./run
```

## Stow packages

Each directory is a [GNU Stow](https://www.gnu.org/software/stow/) package.
`stow --restow <pkg>` symlinks its contents into `$HOME`.

| Package    | Targets                    |
|------------|----------------------------|
| `git`      | `~/.gitconfig`             |
| `nvim`     | `~/.config/nvim/`          |
| `starship` | `~/.config/starship.toml`  |
| `zsh`      | `~/.zshrc`, `~/.zshenv`    |
| `zellij`   | `~/.config/zellij/`        |
| `skhd`     | `~/.config/skhd/`          |
| `yabai`    | `~/.config/yabai/`         |
| `sketchybar` | `~/.config/sketchybar/`  |

`shell/` is **not** stowed — it's sourced directly via `$DOTFILES/shell/...` in `.zshrc`.

## SketchyBar

TokyoNight status bar, one bordered pill per widget. Layout:

```
[ 1 2 3 ] ❯   [  Ghostty ]        ·notch·        [ 󰝚 Track — Artist ]   [mem] [wifi] [vol] [batt] [date] [time]
```

- `variables.sh` — palette, font, geometry, and the shared `pill()` styling helper.
- `icons.sh` — **generated**; Nerd Font glyph constants plus the `app_icon()` lookup
  used by `front_app`. Stock Nerd Font glyphs only, no `sketchybar-app-font`.
- `items/<name>.sh` — appearance and subscriptions. `plugins/<name>.sh` — logic.
- `helpers/check_glyphs.sh` — verifies every glyph in `icons.sh` exists in the font.
  A missing glyph renders as a silent tofu box, so run this after editing icons.
- `helpers/media_listener.sh` — bridges `media-control stream` to a custom
  `media_update` event.

Requires **Berkeley Mono** (a paid font, not installable via brew) patched with
Nerd Font — the config expects `BerkeleyMonoVariable Nerd Font Mono` in
`~/Library/Fonts`. Point `FONT` in `variables.sh` at another Nerd Font to change it.

Notes:
- Spaces are display-only. SIP is enabled, so yabai's scripting addition cannot
  load and click-to-focus would silently do nothing.
- The media widget is player-agnostic (TIDAL, Spotify, Music, browsers) via
  `media-control`. SketchyBar's built-in `media_change` event is unreliable since
  macOS 15.4 locked down MediaRemote.

## Adding a new config

1. `mkdir -p <app>/.config/<app>` (mirror the path relative to `$HOME`)
2. Move your config files into it
3. Add the package name to `STOW_PACKAGES` in `run`
4. `stow --restow <app>`
