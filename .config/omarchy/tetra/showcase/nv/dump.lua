-- Usage: nvim --headless -u NONE -l nv/dump.lua <neovim.lua> <source file> <first> <last> <out.json>
-- Loads the theme's aether opts, highlights the excerpt with treesitter and writes, per
-- character, the highlight group that supplies its foreground, plus UI group colours.
local spec_path, src, first, last, out = unpack(arg)
first, last = tonumber(first), tonumber(last)
local lazy = vim.fn.expand('~/.local/share/nvim/lazy/')
vim.opt.rtp:prepend(lazy .. 'aether')
vim.opt.rtp:prepend(lazy .. 'nvim-treesitter/runtime')
vim.opt.rtp:prepend(vim.fn.expand('~/.local/share/nvim/site'))
vim.o.termguicolors = true
local spec = dofile(spec_path)[1]
require('aether').setup(spec.opts)
vim.cmd.colorscheme('aether')

local lines = vim.list_slice(vim.fn.readfile(src), first, last)
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
vim.bo[buf].filetype = 'python'
vim.treesitter.start(buf, 'python')
vim.treesitter.get_parser(buf):parse(true)

-- follow links to the group that actually defines fg
local function resolve(name)
  for _ = 1, 20 do
    local h = vim.api.nvim_get_hl(0, { name = name, link = true })
    if h.link then name = h.link else return name, h end
  end
end
local hex = function(n) return n and string.format('#%06x', n) or nil end

local groups, rows = {}, {}
for r, line in ipairs(lines) do
  local row = {}
  for col = 0, #line - 1 do
    local g = ''
    local caps = vim.inspect_pos(buf, r - 1, col, { treesitter = true, syntax = false, extmarks = false, semantic_tokens = false }).treesitter
    -- captures come in priority order; the last one with a foreground wins
    -- higher priority wins; at equal priority the later capture wins, as in the highlighter
    for i, cap in ipairs(caps) do cap.i = i end
    table.sort(caps, function(a, b)
      local pa, pb = tonumber(a.metadata.priority) or 100, tonumber(b.metadata.priority) or 100
      if pa ~= pb then return pa < pb end
      return a.i < b.i
    end)
    for _, cap in ipairs(caps) do
      local name, h = resolve(cap.hl_group_link)
      if h.fg then g = name; groups[name] = { fg = hex(h.fg), italic = h.italic, bold = h.bold } end
    end
    row[#row + 1] = g
  end
  rows[#rows + 1] = row
end
local ui = {}
for _, n in ipairs({ 'Normal', 'LineNr', 'CursorLineNr', 'CursorLine', 'SignColumn', 'Visual', 'Cursor',
  'GitSignsAdd', 'GitSignsChange', 'GitSignsDelete', 'StatusLine', 'TabLine', 'TabLineSel', 'TabLineFill',
  'MsgArea', 'ModeMsg', 'BufferLineFill', 'BufferLineBufferSelected', 'BufferLineBackground',
  'SnacksIndent', 'SnacksIndentScope', 'WinSeparator', 'EndOfBuffer' }) do
  local name, h = resolve(n)
  ui[n] = { group = name, fg = hex(h.fg), bg = hex(h.bg), italic = h.italic, bold = h.bold, sp = hex(h.sp) }
end
local lualine = require('lualine.themes.aether')
local f = io.open(out, 'w')
f:write(vim.json.encode({ rows = rows, groups = groups, ui = ui, lualine = lualine, colors = spec.opts.colors }))
f:close()
