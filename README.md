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

`shell/` is **not** stowed — it's sourced directly via `$DOTFILES/shell/...` in `.zshrc`.

## Adding a new config

1. `mkdir -p <app>/.config/<app>` (mirror the path relative to `$HOME`)
2. Move your config files into it
3. Add the package name to `STOW_PACKAGES` in `run`
4. `stow --restow <app>`
