-- This is going to be the meat of the plugin.
function load_custom_snippets(luasnip) -- TODO: Break each language out into its own file
  local snippet = luasnip.snippet
  local snippet_node = luasnip.snippet_node
  local insert = luasnip.insert_node
  local choice = luasnip.choice_node
  local dynamic = luasnip.dynamic_node
  local func = luasnip.function_node
  local text_node = luasnip.text_node
  local repeated = require('luasnip.extras').rep
  local format_args = require('luasnip.extras.fmt').fmta

  local snippet_collection = require 'luasnip.session.snippet_collection'

  -------------------------------
  --------- Lua snippets --------
  -------------------------------
  snippet_collection.clear_snippets 'lua'

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

  luasnip.add_snippets('lua', {
    snippet(
      'require',
      format_args('local <var> = require(\'<module>\')', {
        var = func(resolve_variable_name, { 1 }),
        module = insert(1),
      })
    ),
    snippet('exp', text_node 'local exports = {}\nreturn exports'),
    snippet(
      'exp_tbl',
      format_args('exports.<name> = {\n<body>\n}', {
        name = insert(1),
        body = insert(0),
      })
    ),
    snippet(
      'exp_fn',
      format_args('exports.<name> = function(<args>)\n\t<body>\nend', {
        name = insert(1),
        args = insert(2),
        body = insert(0),
      })
    ),
  })

  -------------------------------
  --------- Go Snippets ---------
  -------------------------------
  snippet_collection.clear_snippets 'go'

  local go_return_values = function(args)
    local default_values = {
      int = '0',
      int32 = '0',
      int64 = '0',
      uint = '0',
      uint32 = '0',
      uint64 = '0',
      bool = 'false',
      float = '0.0',
      float32 = '0.0',
      float64 = '0.0',
      string = '""',
      error = function(_, info)
        if info then
          info.index = info.index + 1

          return choice(info.index, {
            text_node(info.err_name),
            format_args('fmt.Errorf("<msg>", <args>)', {
              msg = insert(1, info.func_name),
              args = insert(0),
            }),
            format_args('gerr.ErrInternal("<msg>", <args>)', {
              msg = insert(1, info.func_name),
              args = insert(0),
            }),
          })
        else
          return text_node 'err'
        end
      end,
      -- Types with a "*" mean they are pointers, so return nil
      [function(text)
        return string.find(text, '*', 1, true) ~= nil
      end] = function(_, _)
        return text_node 'nil'
      end,
      -- Usually no "*" and Capital is a struct type, so give the option to have
      -- or, if there is a ".", the capital will be after the package name
      -- it be with {} as well
      [function(text)
        local has_pointer = string.find(text, '*', 1, true) ~= nil
        local is_capital = string.upper(string.sub(text, 1, 1)) == string.sub(text, 1, 1)

        local dot_index = string.find(text, '.', 1, true)
        local in_package = dot_index ~= nil

        local in_package_capital = false
        if in_package then
          in_package_capital = string.upper(string.sub(text, dot_index + 1, dot_index + 1))
            == string.sub(text, dot_index + 1, dot_index + 1)
        end

        return not has_pointer and (is_capital or (in_package and in_package_capital))
      end] = function(text, info)
        info.index = info.index + 1

        return choice(info.index, {
          text_node(text .. '{}'),
          text_node(text),
        })
      end,
    }

    local transform = function(txt, info)
      -- Transforms some text into a snippet node
      -- @param text string
      -- @param info table

      -- Determines whether the key matches the condition
      local condition_matches = function(condition, ...)
        if type(condition) == 'string' then
          return condition == txt
        else
          return condition(...)
        end
      end

      -- Find the matching condition to get the correct default value
      for condition, result in pairs(default_values) do
        if condition_matches(condition, txt, info) then
          if type(result) == 'string' then
            return text_node(result)
          else
            return result(txt, info)
          end
        end
      end

      -- If no condition matches, return the original text
      return text_node(txt)
    end

    local handlers = {
      parameter_list = function(node, info)
        local result = {}

        local count = node:named_child_count()
        for idx = 0, count - 1 do
          local matching_mode = node:named_child(idx)
          local type_node = matching_mode:field('type')[1]
          table.insert(result, transform(vim.treesitter.get_node_text(type_node, 0), info))
          if idx ~= count - 1 then
            table.insert(result, text_node ', ')
          end
        end

        return result
      end,

      type_identifier = function(node, info)
        local text = vim.treesitter.get_node_text(node, 0)
        return { transform(text, info) }
      end,

      qualified_type = function(node, info)
        local type_node = nil
        local package_node = nil

        for child in node:iter_children() do
          if child:type() == 'type_identifier' then
            type_node = child
          elseif child:type() == 'package_identifier' then
            package_node = child
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

    return snippet_node(
      nil,
      go_result_type {
        index = 0,
        err_name = args[1][1],
        func_name = args[2][1],
      }
    )
  end

  local go_function_name = function()
    local function_node_types = {
      function_declaration = true,
      method_declaration = true,
      func_literal = true,
    }
    local node = vim.treesitter.get_node()
    while node ~= nil do
      if function_node_types[node:type()] then
        vim.notify(node:type(), vim.log.levels.INFO)
        break
      end

      node = node:parent()
    end

    if node == nil then
      vim.notify('Could not find function node', vim.log.levels.ERROR)
      return '<nil>'
    end

    local result = ''
    local name = node:field('name')[1]
    if name then
      result = result .. vim.treesitter.get_node_text(name, 0)
    end

    if node:type() == 'method_declaration' then
      local reciever = node:field('receiver')[1]
      if reciever then
        local reciever_name = vim.treesitter.get_node_text(reciever, 0)
        if reciever_name ~= '' then
          local parts = vim.split(reciever_name, ' ', {
            plain = true,
            trimempty = true,
          })
          local struct_name = parts[#parts]
          struct_name = struct_name:gsub('[()]', '')

          result = struct_name .. '.' .. result
        end
      end
    end

    if result == '' then
      vim.notify('No function name', vim.log.levels.ERROR)
      return '<nil>'
    end

    return result
  end

  luasnip.add_snippets('go', {
    snippet(
      'test',
      format_args('func Test<name>(t *testing.T) {\n\t<body>\n}', {
        name = insert(1),
        body = insert(0),
      })
    ),
    snippet(
      'benchmark',
      format_args('func Benchmark<name>(b *testing.B) {\n\t<body>\n}', {
        name = insert(1),
        body = insert(0),
      })
    ),
    snippet(
      'iferr',
      format_args(
        [[
<val>, <err> := <f>(<args>)
if <err_rep> != nil {
	return <result>
}
<finish>
		]],
        {
          val = insert(1, '_'),
          err = insert(2, 'err'),
          f = insert(3),
          args = insert(4),
          err_rep = repeated(2),
          result = dynamic(5, go_return_values, { 2, 3 }),
          finish = insert(0),
        }
      )
    ),
    snippet(
      'iferr-inline',
      format_args(
        [[
if <val>, <err> := <f>(<args>); <err> != nil {
	return <result>
}
<finish>
		]],
        {
          val = insert(1, '_'),
          err = insert(2, 'err'),
          f = insert(3),
          args = insert(4),
          result = dynamic(5, go_return_values, { 2, 3 }),
          finish = insert(0),
        }
      )
    ),
    snippet(
      'dbg',
      format_args('fmt.Printf("[<fn_name>]: <msg>\\n", <args>)', {
        fn_name = func(go_function_name),
        msg = insert(1, 'Debugging'),
        args = insert(0),
      })
    ),
  })
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
