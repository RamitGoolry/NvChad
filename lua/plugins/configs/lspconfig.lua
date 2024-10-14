dofile(vim.g.base46_cache .. 'lsp')
require 'nvchad.lsp'

local exports = {}
local utils = require 'core.utils'

-- export on_attach & capabilities for custom lspconfigs

exports.on_attach = function(client, bufnr)
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

exports.capabilities = vim.lsp.protocol.make_client_capabilities()

exports.capabilities.textDocument.completion.completionItem = {
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
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = exports.capabilities,

  settings = {
    Lua = {
      hint = {
        enable = true,
      },
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
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = exports.capabilities,
  settings = {
    ['rust-analyzer'] = {
      assist = {
        importGranularity = 'module',
        importPrefix = 'by_self',
      },
      cargo = {
        loadOutDirsFromCheck = true,
        autoReload = true,
      },
      completion = {
        autoimport = {
          enable = true,
        },
        fullFunctionSignatures = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = {
          enable = true,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
        },
        discriminantHints = {
          enable = true,
        },
        implicitDrops = {
          enable = false,
        },
        lifetimeElisionHints = {
          enable = true,
          useParameterNames = true,
        },
        rangeExclusiveHints = {
          enable = true,
        },
        reborrowHints = {
          enable = true,
        },
      },
    },
  },
}

lspconfig.gopls.setup {
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = exports.capabilities,
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        appends = true,
        assign = true,
        atomic = true,
        nilness = true,
        fillreturns = true,
        httpresponse = true,
        ifaceassert = true,
        loopclosure = true,
        unusedparams = false,
        unusedwrite = true,
        useany = true,
        shadow = false,
        unusedvariable = true,
      },
      experimentalPostfixCompletions = true,
      staticcheck = true,
      gofumpt = true,
    },
  },
}

lspconfig.ts_ls.setup {
  on_attach = exports.on_attach,
  capabilities = exports.capabilities,
}

-- lspconfig.golangci_lint_ls.setup {
--   on_attach = exports.on_attach,
--   capabilities = exports.capabilities,
-- }

-- lspconfig.pyright.setup {
--   on_attach = M.on_attach,
--   capabilities = M.capabilities,
--   settings = {
--     python = {
--       analysis = {
--         autoSearchPaths = true,
--         useLibraryCodeForTypes = true,
--       },
--     },
--   },
-- }

lspconfig.basedpyright.setup {
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,

  capabilities = exports.capabilities,
  settings = {
    basedpyright = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportDeprecated = false,
          reportAssignmentType = false,
          reportAny = false,
          reportMissingModuleSource = false,
          reportMissingTypeArgument = false,
          reportMissingParameterType = false,
          reportUnknownVariableType = false,
          reportPrivateLocalImportUsage = false,
          reportPrivateUsage = false,
          reportUnreachable = false,
          reportUnknownArgumentType = false,
          reportUnknownLambdaType = false,
          reportUnknownMemberType = false,
          reportUnknownParameterType = false,
          reportAttributeAccessIssue = false,
          reportIgnoreCommentWithoutRule = false,
          reportUninitializedInstanceVariable = false,
          reportUnusedCallResult = false,
          reportImplicitOverride = false,
          reportUntypedFunctionDecorator = false,
          reportArgumentType = false,
          reportImplicitStringConcatenation = false,
          reportUnnecessaryTypeIgnoreComment = false,
          reportUnnecessaryComparison = 'information',
          reportUnnecessaryIsInstance = 'information',
        },
      },
    },
  },
}

lspconfig.terraformls.setup {
  on_attach = exports.on_attach,
  capabilities = exports.capabilities,
}

lspconfig.jsonls.setup {
  on_attach = exports.on_attach,
  capabilities = exports.capabilities,
  settings = {
    json = {
      schemas = require('schemastore').json.schemas {
        select = {
          '.eslintrc',
          'prettierrc.json',
          'package.json',
        },
      },
      validate = {
        enable = true,
      },
    },
  },
}

-- FIXME: YAMLLS SCREAMS SO MUCH I FORGOT
-- lspconfig.yamlls.setup {
-- 	on_attach = exports.on_attach,
-- 	capabilities = exports.capabilities,
-- 	settings = {
-- 		yaml = {
-- 			schemas = require('schemastore').yaml.schemas {
-- 				'Helm Chart.yaml',
-- 			},
-- 			schemaStore = {
-- 				enable = false,
-- 				url = '',
-- 			},
-- 		},
-- 	},
-- }

lspconfig.nil_ls.setup {
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = exports.capabilities,
}

lspconfig.helm_ls.setup {
  settings = {
    ['helm-ls'] = {
      yamlls = {
        enabled = true,
        path = 'yaml-language-server',
      },
    },
  },
}

lspconfig.sourcekit.setup {
  cmd = {
    'xcrun',
    'sourcekit-lsp',
    '-Xswiftc',
    '-sdk',
    '-Xswiftc',
    '/Applications/Xcode.app/Contents/Developer/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk',
    '-Xswiftc',
    '-target',
    '-Xswiftc',
    'arm64-apple-xros1.0-simulator',
  },
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = exports.capabilities,
}

lspconfig.gleam.setup {}

return exports
