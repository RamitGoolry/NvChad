local opts = {
  lazygit = {},
  picker = {},
  terminal = {},
}

-- Custom theme picker function
opts.theme_picker = function()
  local snacks = require 'snacks'

  -- Get list of available themes
  local theme_path = vim.fn.stdpath 'data' .. '/lazy/base46/lua/base46/themes'
  local themes = {}

  -- Scan theme directory
  local scan = vim.loop.fs_scandir(theme_path)
  if scan then
    while true do
      local name, type = vim.loop.fs_scandir_next(scan)
      if not name then
        break
      end
      if type == 'file' and name:match '%.lua$' then
        local theme_name = name:gsub('%.lua$', '')
        table.insert(themes, theme_name)
      end
    end
  end

  -- Sort themes alphabetically
  table.sort(themes)

  -- Store current theme to restore if cancelled
  local current_theme = vim.g.nvchad_theme
  local base46 = require 'base46'
  local last_preview = nil

  -- Get current buffer content for preview
  local current_buf = vim.api.nvim_get_current_buf()
  local preview_lines = vim.api.nvim_buf_get_lines(
    current_buf,
    0,
    math.min(100, vim.api.nvim_buf_line_count(current_buf)),
    false
  )
  local preview_ft = vim.bo[current_buf].filetype

  if #preview_lines == 0 or (#preview_lines == 1 and preview_lines[1] == '') then
    preview_lines = {
      'print("Hello, world!")',
    }
    preview_ft = 'python'
  end

  -- Create items from themes list
  local items = {}
  for _, theme in ipairs(themes) do
    table.insert(items, {
      text = theme,
      value = theme,
      file = vim.fn.tempname() .. '_' .. theme .. '.lua', -- Create a temp file path
      lines = preview_lines, -- Add lines for text previewer
      ft = preview_ft,
    })
  end

  -- Use the generic picker with proper configuration
  snacks.picker {
    source = 'list',
    title = 'Select Theme',
    items = items,
    layout = {
      preset = 'default',
      preview = true, -- Enable preview
    },
    format = function(item)
      if item and item.text then
        return {
          { '  ', hl = 'SnacksPickerIcon' },
          { item.text },
        }
      end
      return {}
    end,
    preview = 'preview', -- Use built-in text previewer
    on_change = function(picker, item)
      if item and item.value and last_preview ~= item.value then
        last_preview = item.value
        vim.schedule(function()
          vim.g.nvchad_theme = item.value
          base46.load_all_highlights()
        end)
      end
    end,
    actions = {
      confirm = function(picker, item)
        if item and item.value then
          vim.g.nvchad_theme = item.value
          base46.load_all_highlights()
          picker:close()
        end
      end,
      cancel = function(picker)
        -- Restore original theme
        vim.g.nvchad_theme = current_theme
        base46.load_all_highlights()
        picker:close()
      end,
    },
  }
end

return opts
