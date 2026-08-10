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
| `shell`    | `~/.config/.aliases`, `~/.config/.functions`, `~/.config/completion.zsh` |

`shell/` **is** stowed — `.zshrc` sources `$HOME/.config/.aliases` and friends,
which stow symlinks back here. (It was previously documented as "not stowed,
sourced directly from `$DOTFILES`", which was never true: those were real,
untracked files and the repo copies had gone stale.)

## Drift

`stow` does nothing when a target already exists as a real file, and says so
only in passing. When that happens the config still works, so nothing looks
wrong — but edits go to an untracked copy and the repo silently rots. This bit
`nvim`, `zsh`, `zellij`, `skhd` and `shell` for months.

Two guards:

- `run` refuses to stow if any target is a real file, and prints the offenders.
- The `<app>config` aliases point into `$DOTFILES` rather than `~/.config`, so
  editing always touches the tracked file and a wrong path fails loudly.

To check by hand:

```bash
ls -l ~/.config/nvim ~/.zshrc ~/.config/.aliases   # want symlinks, not files
```

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
- `yabairc` reserves the bar strip with `external_bar all:30:0`. That 30 must be
  kept in step with `BAR_HEIGHT` in `variables.sh`.

## Adding a new config

1. `mkdir -p <app>/.config/<app>` (mirror the path relative to `$HOME`)
2. Move your config files into it
3. Add the package name to `STOW_PACKAGES` in `run`
4. `stow --restow <app>`
