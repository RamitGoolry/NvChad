# AGENTS.md - Neovim Configuration Development Guide

## Build/Test Commands
- **Format Lua**: `stylua .` (uses .stylua.toml config)
- **Test single file**: Use `:source %` in Neovim to test Lua files
- **Reload config**: `:lua require('plenary.reload').reload_module('module_name')`
- **Plugin management**: `:Lazy` for plugin operations
- **LSP diagnostics**: `:LspInfo` to check LSP status

## Code Style Guidelines
- **Indentation**: 2 spaces (configured in .stylua.toml)
- **Line width**: 120 characters max
- **Quote style**: Auto-prefer double quotes
- **Function calls**: No parentheses for single string/table args
- **Imports**: Use `require 'module'` for single modules, `local mod = require 'module'` for usage
- **Variable naming**: snake_case for locals, PascalCase for modules
- **Table structure**: Prefer explicit key-value pairs, trailing commas allowed

## File Organization
- **Core config**: `lua/core/` - bootstrap, mappings, utils, default config
- **Plugin configs**: `lua/plugins/configs/` - individual plugin configurations
- **Custom overrides**: `lua/custom/` - user customizations (chadrc.lua)
- **Queries**: `queries/` - treesitter query files

## Error Handling
- Use `pcall()` for potentially failing operations
- Prefer early returns over deep nesting
- Use `vim.notify()` for user-facing messages
- Check plugin availability before configuration: `if not pcall(require, 'plugin') then return end`

## Plugin Patterns
- Use lazy loading with appropriate events/commands
- Configure in `lua/plugins/configs/` and reference in `lua/plugins/init.lua`
- Follow NvChad's plugin structure with `opts` and `config` functions
- Use `utils.load_mappings()` for keybinding registration