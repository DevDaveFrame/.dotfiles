return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
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
		legacy_commands = false,
		workspaces = {
			{
				name = "me",
				path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/me",
				overrides = {
					daily_notes = {
						-- Optional, if you keep daily notes in a separate directory.
						folder = "habits/daily",
						-- Optional, if you want to change the date format for the ID of daily notes.
						date_format = "YYYY-MM-DD-dddd-[Week]-ww",
						alias_format = "MMMM D, YYYY,",
						default_tags = { "daily-notes" },
						template = "daily.md",
					},
					templates = {
						folder = "templates",
						date_format = "YYYY-MM-DD-dddd-[Week]-ww",
						time_format = "HH:mm",
						-- A map for custom variables, the key should be the variable and the value a function
						substitutions = {
							["date:ww"] = function()
								local date = os.date("*t")
								return tostring(math.floor((date.yday + date.wday) / 7))
							end,
							["date:DDDD"] = function()
								return tostring(os.date("*t").yday)
							end,
							["date:YYYY"] = function()
								return tostring(os.date("*t").year)
							end,
						},
					},
				},
			},
			{
				name = "work",
				path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work",
				overrides = {
					daily_notes = {
						-- Optional, if you keep daily notes in a separate directory.
						folder = "InformaTechTarget/2026/dailies",
						-- Optional, if you want to change the date format for the ID of daily notes.
						date_format = "YYYY-MM-DD-dddd-[Week]-ww",
						alias_format = "MMMM D, YYYY,",
						default_tags = { "daily-notes" },
						template = "Daily.md",
					},
					templates = {
						folder = "Templates",
						date_format = "YYYY-MM-DD-dddd-[Week]-ww",
						time_format = "HH:mm",
						-- A map for custom variables, the key should be the variable and the value a function
						substitutions = {
							["date:ww"] = function()
								local date = os.date("*t")
								return tostring(math.floor((date.yday + date.wday) / 7))
							end,
							["date:DDDD"] = function()
								return tostring(os.date("*t").yday)
							end,
							["date:YYYY"] = function()
								return tostring(os.date("*t").year)
							end,
						},
					},
				},
			},
		},
	},
}
