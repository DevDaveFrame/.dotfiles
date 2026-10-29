local pks = function()
	return require("config.pks")
end

return {
<<<<<<< Updated upstream
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
	-- init runs at startup even though the plugin itself is lazy, so the command
	-- exists before any markdown buffer is opened (obs-work calls it via -c).
	init = function()
		-- One running scratch file instead of a daily note per day: each call
		-- appends a timestamp heading and drops into insert mode beneath it.
		vim.api.nvim_create_user_command("ScratchNote", function()
			local path = vim.fn.expand("~/Documents/Notes/scratch.md")
			-- Guard rather than always :edit, which errors (E37) when re-run on
			-- the already-open, unsaved scratch buffer.
			if vim.api.nvim_buf_get_name(0) ~= path then
				vim.cmd.edit(vim.fn.fnameescape(path))
			end

			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local last = #lines
			while last > 0 and lines[last]:match("^%s*$") do
				last = last - 1
			end

			local entry = { os.date("## %Y-%m-%d %a %H:%M"), "" }
			if last > 0 then
				table.insert(entry, 1, "")
			end
			-- Replaces any trailing blank lines so entries stay one blank line apart.
			vim.api.nvim_buf_set_lines(0, last, -1, false, entry)
			vim.api.nvim_win_set_cursor(0, { last + #entry, 0 })
			vim.cmd.startinsert()
		end, { desc = "Append a timestamp to scratch.md and start typing" })
	end,
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "work",
				path = "~/Documents/Notes/",
				overrides = {
					daily_notes = {
						-- Optional, if you keep daily notes in a separate directory.
						folder = "Dailies",
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
||||||| Stash base
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
=======
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		-- Load only for notes inside the iCloud vaults, not for every markdown file.
		event = {
			{ event = { "BufReadPre", "BufNewFile" }, pattern = vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/*.md" },
		},
		cmd = "Obsidian",
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
		keys = {
			{ "<leader>o", "", desc = "+obsidian" },
			{ "<leader>on", function() pks().new_note("zettel") end, desc = "New Note (inbox)" },
			{ "<leader>oN", "<cmd>Obsidian new_from_template<cr>", desc = "New Note from Template" },
			{ "<leader>of", "<cmd>Obsidian quick_switch<cr>", desc = "Find Note" },
			{ "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search Vault" },
			{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
			{ "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Outgoing Links" },
			{ "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Tags" },
			{ "<leader>od", "<cmd>Obsidian today<cr>", desc = "Daily Note" },
			{ "<leader>oi", function() pks().inbox() end, desc = "Inbox" },
			{ "<leader>oO", function() pks().orphans() end, desc = "Orphan Notes" },
			{ "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename Note" },
			{ "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Insert Template" },
			{ "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian App" },
			{ "<leader>oe", "<esc><cmd>lua require('config.pks').extract()<cr>", mode = "x", desc = "Extract to Note" },
			{ "<leader>ok", ":Obsidian link<cr>", mode = "x", desc = "Link Selection to Note" },
		},
		---@module 'obsidian'
		---@type obsidian.config
		opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "me",
					path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/me",
					-- Zettelkasten-lite setup; helpers in lua/config/pks.lua.
					overrides = {
						-- New notes are fleeting: they land in inbox/ and get promoted to notes/ once processed.
						notes_subdir = "inbox",
						new_notes_location = "notes_subdir",
						-- Readable titles as filenames; the stable timestamp id lives in the frontmatter.
						note_id_func = function(title, dir)
							return require("config.pks").note_id(title, dir)
						end,
						note = { template = "zettel" },
						-- Templates own the frontmatter, so notes look the same whether created here or in the app.
						frontmatter = { enabled = false },
						daily_notes = {
							folder = "daily",
							date_format = "YYYY-MM-DD",
							template = "daily",
							default_tags = {},
							workdays_only = false,
						},
						templates = {
							folder = "templates",
							date_format = "YYYY-MM-DD-dddd-[Week]-ww",
							time_format = "HH:mm",
							customizations = {
								zettel = { notes_subdir = "inbox" },
								source = { notes_subdir = "sources" },
							},
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
						link = { style = "wiki", format = "shortest", auto_update = true },
						attachments = { folder = "attachments" },
						picker = { name = "snacks.picker" },
						-- render-markdown.nvim does the rendering.
						ui = { enable = false },
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
>>>>>>> Stashed changes
						},
					},
				},
			},
		},
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		opts = {
			code = { sign = false, width = "block", right_pad = 1 },
			heading = { sign = false },
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)
			Snacks.toggle({
				name = "Render Markdown",
				get = require("render-markdown").get,
				set = require("render-markdown").set,
			}):map("<leader>um")
		end,
	},
}
