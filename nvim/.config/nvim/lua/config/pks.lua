-- Helpers for the "me" vault zettelkasten (used by lua/plugins/obsidian.lua).
local M = {}

M.vault = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/me")

-- Folders that hold "real" notes, i.e. the ones that should be linked from somewhere.
local linkable_dirs = { "inbox", "notes", "sources" }

-- Filename for a note title: readable, but safe for the filesystem and for Obsidian links.
function M.note_id(title, dir)
  local name = title and vim.trim((title:gsub('[\\/:*?"<>|#^%[%]]', ""):gsub("%s+", " "))) or ""
  if name == "" then
    name = os.date("%Y%m%d%H%M")
  end
  local candidate, n = name, 2
  while dir and vim.uv.fs_stat(vim.fs.joinpath(tostring(dir), candidate .. ".md")) do
    candidate = ("%s %d"):format(name, n)
    n = n + 1
  end
  return candidate
end

-- Put the cursor on the first writing spot of a fresh note: the blank line after the
-- first guidance comment below the title, or the line after the title.
local function goto_body()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local heading
  for i, line in ipairs(lines) do
    if not heading and line:match("^# ") then
      heading = i
    elseif heading and line:match("^<!%-%-") then
      vim.api.nvim_win_set_cursor(0, { math.min(i + 1, #lines), 0 })
      return
    end
  end
  if heading then
    vim.api.nvim_win_set_cursor(0, { math.min(heading + 1, #lines), 0 })
  end
end

---Prompt for a title and create a note from `template` (default "zettel").
---@param template? string
---@param on_abort? fun()
function M.new_note(template, on_abort)
  template = template or "zettel"
  vim.ui.input({ prompt = ("New %s note: "):format(template) }, function(title)
    if title == nil then
      return on_abort and on_abort()
    end
    -- "/" would be read as a folder by obsidian.nvim.
    title = vim.trim((title:gsub("/", "-")))
    if title == "" then
      title = os.date("%Y%m%d%H%M")
    end
    require("obsidian.actions").new_from_template(title, template, function(note)
      note:open({ sync = true })
      goto_body()
      vim.cmd("startinsert!")
    end)
  end)
end

-- Entry point for the system-wide quick-capture window: new inbox note, quit if aborted.
function M.capture()
  local function run()
    M.new_note("zettel", function()
      vim.cmd("qa")
    end)
  end
  if vim.v.vim_did_enter == 1 then
    run()
  else
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = vim.schedule_wrap(run) })
  end
end

-- Extract the last visual selection into a new zettel, replacing it with a link. Unlike
-- `:Obsidian extract_note`, the text goes into the body instead of the end of the note.
function M.extract()
  local count = vim.fn.line("'>") - vim.fn.line("'<") + 1
  vim.ui.input({ prompt = "Extract to note: " }, function(title)
    if title == nil then
      return
    end
    title = vim.trim((title:gsub("/", "-")))
    require("obsidian.actions").extract_note(title ~= "" and title or os.date("%Y%m%d%H%M"))

    -- extract_note opened the new note and appended the selection at the end.
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = vim.list_slice(lines, #lines - count + 1, #lines)
    for i, line in ipairs(lines) do
      if line:match("^<!%-%- One idea") then
        vim.api.nvim_buf_set_lines(0, #lines - count, #lines, false, {})
        vim.api.nvim_buf_set_lines(0, i, i, false, content)
        vim.api.nvim_win_set_cursor(0, { i + 1, 0 })
        break
      end
    end
  end)
end

-- Notes in inbox/, notes/ and sources/ that no other note links to.
function M.orphans()
  local function rg(args)
    local res = vim.system(vim.list_extend({ "rg", "--glob", "*.md", "--glob", "!templates/**" }, args), {
      cwd = M.vault,
      text = true,
    }):wait()
    return vim.split(res.stdout or "", "\n", { trimempty = true })
  end
  local function stem(path)
    return vim.fs.basename(path):gsub("%.md$", ""):lower()
  end

  -- Every "file\0[[target" / "file\0](target.md" occurrence in the vault.
  local linked = {}
  for _, line in ipairs(rg({ "--null", "--only-matching", "--no-line-number", "-e", [[\[\[[^\]|#^]+]], "-e", [[\]\([^)#]+\.md]] })) do
    local file, match = line:match("^(.-)%z(.*)$")
    if file then
      local target = match:gsub("^%[%[", ""):gsub("^%]%(", ""):gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
      end)
      target = stem(vim.trim(target))
      if target ~= stem(file) then
        linked[target] = true
      end
    end
  end

  local items = {}
  for _, file in ipairs(rg(vim.list_extend({ "--files" }, linkable_dirs))) do
    if not linked[stem(file)] then
      items[#items + 1] = { file = vim.fs.joinpath(M.vault, file), text = file }
    end
  end
  table.sort(items, function(a, b)
    return a.text < b.text
  end)

  if #items == 0 then
    return vim.notify("No orphan notes", vim.log.levels.INFO, { title = "pks" })
  end
  Snacks.picker.pick({ title = "Orphan notes", items = items, format = "file" })
end

function M.inbox()
  Snacks.picker.files({ title = "Inbox", cwd = vim.fs.joinpath(M.vault, "inbox") })
end

return M
