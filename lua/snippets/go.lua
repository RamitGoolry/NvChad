local luasnip = require 'luasnip'
local snippet = luasnip.snippet
local snippet_node = luasnip.snippet_node
local insert = luasnip.insert_node
local choice = luasnip.choice_node
local dynamic = luasnip.dynamic_node
local func = luasnip.function_node
local text_node = luasnip.text_node
local repeated = require('luasnip.extras').rep
local format_args = require('luasnip.extras.fmt').fmta

local transform = function(text, info)
  local function_name = info.parent.parent.env.TM_FILENAME:match '^(.*)%.' or ''
  if text == function_name then
    return text
  else
    return function_name .. text
  end
end

local handlers = {
  ['parameter_list'] = function(node, info)
    local result = {}

    local count = node:named_child_count()
    for idx = 0, count - 1 do
      local matching_node = node:named_child(idx)
      local type_node = matching_node:field('type')[1]
      table.insert(result, transform(vim.treesitter.get_node_text(type_node, 0), info))
    end

    return result
  end,

  ['type_identifier'] = function(node, info)
    local text = vim.treesitter.get_node_text(node, 0)
    return { transform(text, info) }
  end,

  ['pointer_type'] = function(node, info)
    local type_node = node:named_child(0)
    local type_text = vim.treesitter.get_node_text(type_node, 0)
    return { '*' .. transform(type_text, info) }
  end,

  ['slice_type'] = function(node, info)
    local type_node = node:named_child(0)
    local type_text = vim.treesitter.get_node_text(type_node, 0)
    return { '[]' .. transform(type_text, info) }
  end,

  ['qualified_type'] = function(node, info)
    local package_node = node:field('package')[1]
    local type_node = node:field('name')[1]

    if not type_node then
      for idx = 0, node:named_child_count() - 1 do
        local child = node:named_child(idx)
        if child:type() == 'type_identifier' then
          type_node = child
          break
        end
      end
    end

    assert(type_node, 'Could not find type node in qualified_type capture')
    local type_text = vim.treesitter.get_node_text(type_node, 0)

    if package_node then
      local package_text = vim.treesitter.get_node_text(package_node, 0)
      type_text = package_text .. '.' .. type_text
    end

    return { transform(type_text, info) }
  end,
}

local go_result_type = function(info)
  local function_node_types = {
    function_declaration = true,
    method_declaration = true,
    func_literal = true,
  }

  -- Find the first function node that's a parent of the cursor
  local node = vim.treesitter.get_node()
  while node ~= nil do
    if function_node_types[node:type()] then
      break
    end

    node = node:parent()
  end

  -- Exit early if we couldn't find a function node
  if node == nil then
    vim.notify('Could not find function node', vim.log.levels.ERROR)
    return text_node ''
  end

  -- This file is in `~/.config/nvim/queries/go/return-snippet.scm`
  local query = assert(
    vim.treesitter.query.get('go', 'return-snippet'),
    'Could not load return-snippet.scm'
  )
  for _, capture in query:iter_captures(node, 0) do
    if handlers[capture:type()] then
      return handlers[capture:type()](capture, info)
    end
  end
end

local go_return_values = function(info)
  return snippet_node(
    nil,
    choice(1, {
      text_node { '' },
      snippet_node(nil, {
        text_node { '', '\treturn ' },
        insert(1),
      }),
    })
  )
end

local go_function_snippet = function(info)
  local function_node_types = {
    function_declaration = true,
    method_declaration = true,
    func_literal = true,
  }

  -- Find the first function node that's a parent of the cursor
  local node = vim.treesitter.get_node()
  while node ~= nil do
    if function_node_types[node:type()] then
      break
    end

    node = node:parent()
  end

  -- Exit early if we couldn't find a function node
  if node == nil then
    vim.notify('Could not find function node', vim.log.levels.ERROR)
    return text_node ''
  end

  -- Get the function name
  local name_node = node:field('name')[1]
  if not name_node then
    vim.notify('No function name', vim.log.levels.ERROR)
    return text_node ''
  end

  local function_name = vim.treesitter.get_node_text(name_node, 0)

  -- Get the parameters
  local params_node = node:field('parameters')[1]
  local params = {}
  if params_node then
    for param in params_node:iter_children() do
      if param:type() == 'parameter_declaration' then
        local param_name_node = param:field('name')[1]
        if param_name_node then
          table.insert(params, vim.treesitter.get_node_text(param_name_node, 0))
        end
      end
    end
  end

  -- Build the function call
  local call_text = function_name .. '('
  for i, param in ipairs(params) do
    if i > 1 then
      call_text = call_text .. ', '
    end
    call_text = call_text .. param
  end
  call_text = call_text .. ')'

  return text_node(call_text)
end

return {
  snippet(
    'ife',
    format_args('if err != nil {\n\treturn <result_type>\n}<finish>', {
      result_type = dynamic(1, go_result_type),
      finish = insert(0),
    })
  ),
  snippet(
    'ifew',
    format_args('if err != nil {\n\treturn <result_type>\n}<finish>', {
      result_type = dynamic(1, go_result_type),
      finish = insert(0),
    })
  ),
  snippet(
    'iferr',
    format_args('if <err> != nil {\n\t<return>\n}<finish>', {
      err = insert(1, 'err'),
      ['return'] = choice(2, {
        snippet_node(nil, {
          text_node 'return ',
          dynamic(1, go_result_type),
        }),
        snippet_node(nil, {
          text_node 'return fmt.Errorf("',
          insert(1, 'failed to '),
          text_node ': %w", ',
          repeated(1),
          text_node ')',
        }),
        snippet_node(nil, {
          insert(1, '// handle error'),
        }),
      }),
      finish = insert(0),
    })
  ),
  snippet(
    'fn',
    format_args('func <name>(<params>) <result> {\n\t<body>\n}', {
      name = insert(1, 'name'),
      params = insert(2),
      result = insert(3),
      body = insert(0),
    })
  ),
  snippet(
    'meth',
    format_args('func (<receiver>) <name>(<params>) <result> {\n\t<body>\n}', {
      receiver = insert(1, 'r *Type'),
      name = insert(2, 'Method'),
      params = insert(3),
      result = insert(4),
      body = insert(0),
    })
  ),
  snippet('call', dynamic(1, go_function_snippet)),
}