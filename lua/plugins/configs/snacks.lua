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

  -- Create items from themes list
  local items = {}
  for _, theme in ipairs(themes) do
    table.insert(items, {
      text = theme,
      value = theme,
    })
  end

  -- Use the generic picker with proper configuration
  snacks.picker {
    source = 'list',
    title = 'Select Theme',
    items = items,
    format = function(item)
      if item and item.text then
        return {
          { '  ',     hl = 'SnacksPickerIcon' },
          { item.text },
        }
      end
      return {}
    end,
    preview = function(item, ctx)
      if item and item.value then
        -- Apply theme for preview
        if last_preview ~= item.value then
          last_preview = item.value
          vim.schedule(function()
            vim.g.nvchad_theme = item.value
            base46.load_all_highlights()
          end)
        end

        -- Show sample code in preview
        local lines = {
          '-- Theme: ' .. item.value,
          '',
          'local M = {}',
          '',
          'function M.setup()',
          '  local config = {',
          '                theme = \'' .. item.value .. '\',',
          '    transparent = false,',
          '  }',
          '  return config',
          'end',
          '',
          '-- Sample highlighting',
          'local string = \'Hello, World!\'',
          'local number = 42',
          'local boolean = true',
          'local table = { key = \'value\' }',
          '',
          '-- Control structures',
          'if boolean then',
          '  print(string)',
          'end',
          '',
          'for i = 1, 10 do',
          '  -- Loop body',
          '  local result = i * 2',
          'end',
          '',
          'return M',
        }

        -- Return preview content
        return {
          lines = lines,
          ft = 'lua',
        }
      end
    end,
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
