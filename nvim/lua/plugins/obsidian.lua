return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "me",
        path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/me",
        overrides = {
          templates = {
            folder = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/me/templates",
            date_format = "%Y-%m-%d-%A-Week-%U",
            time_format = "%H:%M",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
          },
        }
      },
      {
        name = "work",
        path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work",
        overrides = {
          daily_notes = {
            -- Optional, if you keep daily notes in a separate directory.
            folder = "Industry Dive/2024/dailies",
            -- Optional, if you want to change the date format for the ID of daily notes.
            date_format = "%Y-%m-%d-%A-Week-%U",
            alias_format = "%B %-d, %Y,",
            default_tags = { "daily-notes" },
            template = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work/Templates/Daily.md"
          }
        }
      },
    },
    -- Optional, for templates (see below).
    templates = {
      folder = "Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "Industry Dive/2024/dailies",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d-%A-Week-%U",
      default_tags = { "daily-notes" },
    }

    -- see below for full list of options 👇
  },
}
