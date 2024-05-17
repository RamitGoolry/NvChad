-- This is going to be the meat of the plugin.
function load_custom_snippets(luasnip)
	local snippet = luasnip.snippet
	local insert = luasnip.insert_node
	local choice = luasnip.choice_node
	local dynamic = luasnip.dynamic_node
	local func = luasnip.function_node
	local text = luasnip.text_node
	local repeated = require('luasnip.extras').rep
	local format_args = require('luasnip.extras.fmt').fmta

	-------------------------------
	--------- Lua snippets --------
	-------------------------------

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
		snippet('exp', text 'local exports = {}\nreturn exports'),
		snippet(
			'exp_tbl',
			format_args('exports.<name> = {\n<body>\n}', {
				name = insert(1),
				body = insert(2),
			})
		),
		snippet(
			'exp_fn',
			format_args('exports.<name> = function(<args>)\n\t<body>\nend', {
				name = insert(1),
				args = insert(2),
				body = insert(3),
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
