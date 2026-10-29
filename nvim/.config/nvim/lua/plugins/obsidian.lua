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
						},
					},
				},
			},
		},
	},
}
