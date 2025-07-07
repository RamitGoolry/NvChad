local opts = {
  lazygit = {},
  picker = {},
  terminal = {},
}

-- Custom theme picker function
opts.theme_picker = function()
  local snacks = require 'snacks'
  
  -- Get list of available themes
  local theme_path = vim.fn.stdpath("data") .. "/lazy/base46/lua/base46/themes"
  local themes = {}
  
  -- Scan theme directory
  local scan = vim.loop.fs_scandir(theme_path)
  if scan then
    while true do
      local name, type = vim.loop.fs_scandir_next(scan)
      if not name then break end
      if type == "file" and name:match("%.lua$") then
        local theme_name = name:gsub("%.lua$", "")
        table.insert(themes, theme_name)
      end
    end
  end
  
  -- Sort themes alphabetically
  table.sort(themes)
  
  -- Store current theme to restore if cancelled
  local current_theme = vim.g.nvchad_theme
  local base46 = require('base46')
  local current_buf = vim.api.nvim_get_current_buf()
  
  snacks.picker.select(themes, {
    prompt = 'Select Theme: ',
    format_item = function(theme)
      return theme
    end,
  }, function(choice, idx)
    if choice then
      vim.g.nvchad_theme = choice
      base46.load_all_highlights()
      vim.cmd('redraw!')
    end
  end)
end

return opts
