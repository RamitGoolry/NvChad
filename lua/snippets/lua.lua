local luasnip = require 'luasnip'
local snippet = luasnip.snippet
local insert = luasnip.insert_node
local func = luasnip.function_node
local text_node = luasnip.text_node
local format_args = require('luasnip.extras.fmt').fmta

local function resolve_variable_name(import_name)
  local name = import_name[1][1]
  local parts = vim.split(name, '.', {
    plain = true,
    trimempty = true,
  })
  -- Remove any instances of "vim" or "nvim" from the variable name
  parts = vim.tbl_filter(function(part)
    return part:lower() ~= 'vim' and part:lower() ~= 'nvim'
  end, parts)

  local last_part = parts[#parts]
  if last_part then
    last_part = last_part:lower()

    -- replace any non-alphanumeric characters with underscores and trim
    last_part = last_part:gsub('[^%w]', '_')
    last_part = last_part:gsub('^[_]*', '')
    last_part = last_part:gsub('[_]*$', '')
  end

  return last_part or 'module'
end

return {
  snippet(
    'require',
    format_args('local <var> = require(\'<module>\')', {
      var = func(resolve_variable_name, { 1 }),
      module = insert(1),
    })
  ),
  snippet(
    'requireplug',
    format_args('require(\'<module>\').setup(<config>)', {
      module = insert(1),
      config = insert(2, '{}'),
    })
  ),
  snippet('fn', {
    text_node 'function(',
    insert(1, 'args'),
    text_node ')',
    text_node { '', '\t' },
    insert(2, '-- body'),
    text_node { '', 'end' },
  }),
  snippet('lfn', {
    text_node 'local function ',
    insert(1, 'name'),
    text_node '(',
    insert(2, 'args'),
    text_node ')',
    text_node { '', '\t' },
    insert(3, '-- body'),
    text_node { '', 'end' },
  }),
}