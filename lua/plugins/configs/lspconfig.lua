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

        -- Disabling certain checks because they are too noisy in the gorilla codebase
        SA1019 = false,
        QF1008 = false,
        deprecated = false,
      },
      experimentalPostfixCompletions = true,
      staticcheck = true,
      gofumpt = true,
    },
  },
}

lspconfig.ts_ls.setup {
  on_attach = function(client, bufnr)
    local twoslash_queries = require 'twoslash-queries'
    twoslash_queries.attach(client, bufnr)
    exports.on_attach(client, bufnr)
  end,
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

-- Function to get pyenv python path
local function get_python_path(workspace)
  -- Use activated virtualenv
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. '/bin/python'
  end

  -- Find and use virtualenv in workspace directory
  for _, pattern in ipairs({'venv', 'env', '.venv'}) do
    local venv_path = workspace .. '/' .. pattern .. '/bin/python'
    if vim.fn.executable(venv_path) == 1 then
      return venv_path
    end
  end

  -- Check for pyenv local version
  local pyenv_local = workspace .. '/.python-version'
  if vim.fn.filereadable(pyenv_local) == 1 then
    local version = vim.fn.readfile(pyenv_local)[1]
    if version then
      -- Trim any whitespace
      version = vim.fn.trim(version)
      local pyenv_python = vim.fn.expand('~/.pyenv/versions/' .. version .. '/bin/python')
      if vim.fn.executable(pyenv_python) == 1 then
        return pyenv_python
      end
    end
  end

  -- Use pyenv which python in the workspace directory
  local handle = io.popen('cd "' .. workspace .. '" && pyenv which python 2>/dev/null')
  if handle then
    local result = handle:read('*a')
    handle:close()
    if result and result ~= '' then
      return vim.fn.trim(result)
    end
  end

  -- Fallback to system python
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

lspconfig.basedpyright.setup {
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,

  capabilities = exports.capabilities,
  
  root_dir = lspconfig.util.root_pattern(
    '.python-version',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git'
  ),
  
  on_new_config = function(config, root_dir)
    local python_path = get_python_path(root_dir)
    config.settings.python = {
      pythonPath = python_path,
    }
    config.settings.basedpyright = config.settings.basedpyright or {}
    config.settings.basedpyright.pythonPath = python_path
    -- Also set the interpreter path for the language server
    config.cmd_env = config.cmd_env or {}
    config.cmd_env.VIRTUAL_ENV = vim.fn.fnamemodify(python_path, ':h:h')
  end,
  
  on_init = function(client)
    -- Notify the server about the python path
    local python_path = client.config.settings.python.pythonPath
    vim.notify('Basedpyright initialized with Python: ' .. python_path, vim.log.levels.INFO)
  end,
  
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
        typeCheckingMode = 'basic',
      },
    },
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
        typeCheckingMode = 'basic',
        autoImportCompletions = true,
        extraPaths = {},
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
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
  },
  on_attach = function(client, bufnr)
    exports.on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = exports.capabilities,
  root_dir = function(filename)
    local dir =
      lspconfig.util.root_pattern('.sourcekit-lsp/config.json', 'Package.swift', '.git')(filename)
    return dir
  end,
}

lspconfig.gleam.setup {}
lspconfig.zls.setup {}
lspconfig.tailwindcss.setup {}

-- Note: Lean LSP is configured by the lean.nvim plugin

-- Command to restart Python LSP with current pyenv
vim.api.nvim_create_user_command('PythonRestartLSP', function()
  vim.cmd('LspRestart basedpyright')
  vim.defer_fn(function()
    vim.notify('Basedpyright restarted', vim.log.levels.INFO)
  end, 500)
end, {})

-- Command to show current Python path
vim.api.nvim_create_user_command('PythonShowPath', function()
  local clients = vim.lsp.get_active_clients()
  local found = false
  for _, client in ipairs(clients) do
    if client.name == 'basedpyright' then
      found = true
      local workspace = client.config.root_dir or vim.fn.getcwd()
      local python_path = get_python_path(workspace)
      local settings_path = client.config.settings and client.config.settings.python and client.config.settings.python.pythonPath
      
      vim.notify(
        'Workspace: ' .. workspace .. 
        '\nDetected Python: ' .. python_path ..
        '\nConfigured Python: ' .. (settings_path or 'not set') ..
        '\nPython version: ' .. vim.fn.system(python_path .. ' --version'),
        vim.log.levels.INFO
      )
    end
  end
  if not found then
    vim.notify('Basedpyright is not running. Open a Python file first.', vim.log.levels.WARN)
  end
end, {})

return exports
