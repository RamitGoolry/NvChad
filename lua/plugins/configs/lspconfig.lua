dofile(vim.g.base46_cache .. 'lsp')
require 'nvchad.lsp'

local M = {}
local utils = require 'core.utils'

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  utils.load_mappings('lspconfig', { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require('nvchad.signature').setup(client)
  end

  if
      not utils.load_config().ui.lsp_semantic_tokens
      and client.supports_method 'textDocument/semanticTokens'
  then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { 'markdown', 'plaintext' },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    },
  },
}

local lspconfig = require 'lspconfig'

lspconfig.lua_ls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = {
          [vim.fn.expand '$VIMRUNTIME/lua'] = true,
          [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
          [vim.fn.stdpath 'data' .. '/lazy/ui/nvchad_types'] = true,
          [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy'] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

lspconfig.rust_analyzer.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  settings = {
    ['rust-analyzer'] = {
      assist = {
        importGranularity = 'module',
        importPrefix = 'by_self',
      },
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
}

lspconfig.gopls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      experimentalPostfixCompletions = true,
      staticcheck = true,
      gofumpt = true,
    },
  },
}

lspconfig.tsserver.setup {
  on_attach = function(_, _)
    -- require("twoslash-queries").attach(client, bufnr)
  end,
}

lspconfig.pyright.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}

lspconfig.terraformls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

lspconfig.yamlls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

lspconfig.helm_ls.setup {
  settings = {
    ['helm-ls'] = {
      yamlls = {
        path = 'yaml-language-server',
      },
    },
  },
}

return M
