local null_ls = require 'null-ls'
local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
local formatting = null_ls.builtins.formatting
-- local diagnostics = null_ls.builtins.diagnostics

local config = {
  debug = true,
  sources = {
    formatting.stylua.with {
      extra_args = { '--quote-style', 'ForceSingle', '--column-width', '100' },
    },
    formatting.black,
    formatting.prettier.with {
      extra_args = { '--config', '.prettierrc' },
    },
    formatting.gofmt,
    formatting.goimports,
    -- formatting.rustfmt,
    -- formatting.golangci_lint,
    -- diagnostics.flake8,
    null_ls.builtins.completion.spell,
  },

  on_init = function(_, _)
    -- new_client.offset_encoding = 'utf-8'
  end,
  on_attach = function(client, bufnr)
    if client.supports_method 'textDocument/formatting' then
      vim.api.nvim_clear_autocmds {
        group = augroup,
        buffer = bufnr,
      }
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })
    end
  end,
}

return config
