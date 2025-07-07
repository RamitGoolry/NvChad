-- Load custom snippets from modular files
local function load_custom_snippets(luasnip)
  require('snippets').load_snippets(luasnip)
end

local exports = {}

exports.load = function(opts)
  local luasnip = require 'luasnip'
  luasnip.config.set_config(opts)

  -- vscode format
  local from_vscode = require 'luasnip.loaders.from_vscode'
  from_vscode.lazy_load()
  from_vscode.lazy_load { paths = vim.g.vscode_snippets_path or '' }

  -- snipmate format
  local from_snipmate = require 'luasnip.loaders.from_snipmate'
  from_snipmate.load()
  from_snipmate.lazy_load { paths = vim.g.snipmate_snippets_path or '' }

  -- lua format
  local from_lua = require 'luasnip.loaders.from_lua'
  from_lua.load()
  from_lua.lazy_load { paths = vim.g.lua_snippets_path or '' }

  load_custom_snippets(luasnip)

  vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function()
      if
        luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
        and not luasnip.session.jump_active
      then
        luasnip.unlink_current()
      end
    end,
  })
end

return exports