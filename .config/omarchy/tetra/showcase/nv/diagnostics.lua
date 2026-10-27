-- Sets nv/diagnostics.json (1-based lines, 0-based columns) on the current buffer, as a
-- language server would: nvim '+luafile nv/diagnostics.lua'
local path = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h') .. '/diagnostics.json'
vim.defer_fn(function()
  local items = {}
  for _, d in ipairs(vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))) do
    items[#items + 1] = { lnum = d.line - 1, col = d.col, end_col = d.end_col,
      severity = vim.diagnostic.severity[d.severity], message = d.message }
  end
  vim.diagnostic.set(vim.api.nvim_create_namespace('tetra-demo'), 0, items)
end, 500)
