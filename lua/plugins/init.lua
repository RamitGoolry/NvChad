-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local default_plugins = {

  'nvim-lua/plenary.nvim',

  {
    'NvChad/base46',
    branch = 'v2.0',
    lazy = false,
    build = function()
      require('base46').load_all_highlights()
    end,
  },

  {
    'NvChad/ui',
    branch = 'v2.0',
    lazy = false,
  },

  {
    'NvChad/nvterm',
    init = function()
      require('core.utils').load_mappings 'nvterm'
    end,
    config = function(_, opts)
      require 'base46.term'
      require('nvterm').setup(opts)
    end,
  },

  {
    'NvChad/nvim-colorizer.lua',
    init = function()
      require('core.utils').lazy_load 'nvim-colorizer.lua'
    end,
    config = function(_, opts)
      require('colorizer').setup(opts)

      -- execute colorizer as soon as possible
      vim.defer_fn(function()
        require('colorizer').attach_to_buffer(0)
      end, 0)
    end,
  },

  {
    'nvim-tree/nvim-web-devicons',
    opts = function()
      return { override = require 'nvchad.icons.devicons' }
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'devicons')
      require('nvim-web-devicons').setup(opts)
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    version = '2.20.7',
    init = function()
      require('core.utils').lazy_load 'indent-blankline.nvim'
    end,
    opts = function()
      return require('plugins.configs.others').blankline
    end,
    config = function(_, opts)
      require('core.utils').load_mappings 'blankline'
      dofile(vim.g.base46_cache .. 'blankline')
      require('indent_blankline').setup(opts)
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    init = function()
      require('core.utils').lazy_load 'nvim-treesitter'
    end,
    cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    build = ':TSUpdate',
    opts = function()
      return require 'plugins.configs.treesitter'
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'syntax')
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- git stuff
  {
    'lewis6991/gitsigns.nvim',
    ft = { 'gitcommit', 'diff' },
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd({ 'BufRead' }, {
        group = vim.api.nvim_create_augroup('GitSignsLazyLoad', { clear = true }),
        callback = function()
          vim.fn.jobstart({ 'git', '-C', vim.loop.cwd(), 'rev-parse' }, {
            on_exit = function(_, return_code)
              if return_code == 0 then
                vim.api.nvim_del_augroup_by_name 'GitSignsLazyLoad'
                vim.schedule(function()
                  require('lazy').load { plugins = { 'gitsigns.nvim' } }
                end)
              end
            end,
          })
        end,
      })
    end,
    opts = function()
      return require('plugins.configs.others').gitsigns
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'git')
      require('gitsigns').setup(opts)
    end,
  },

  -- lsp stuff
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonInstallAll', 'MasonUpdate' },
    opts = function()
      return require 'plugins.configs.mason'
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'mason')
      require('mason').setup(opts)

      -- custom nvchad cmd to install all mason binaries listed
      vim.api.nvim_create_user_command('MasonInstallAll', function()
        if opts.ensure_installed and #opts.ensure_installed > 0 then
          vim.cmd('MasonInstall ' .. table.concat(opts.ensure_installed, ' '))
        end
      end, {})

      vim.g.mason_binaries_list = opts.ensure_installed
    end,
  },

  {
    'neovim/nvim-lspconfig',
    init = function()
      require('core.utils').lazy_load 'nvim-lspconfig'
    end,
    config = function()
      require 'plugins.configs.lspconfig'
    end,
  },

  -- load luasnips + cmp related in insert mode only
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        -- snippet plugin
        'L3MON4D3/LuaSnip',
        dependencies = 'rafamadriz/friendly-snippets',
        opts = { history = true, updateevents = 'TextChanged,TextChangedI' },
        config = function(_, opts)
          require('plugins.configs.others').luasnip(opts)
        end,
      },

      -- autopairing of (){}[] etc
      {
        'windwp/nvim-autopairs',
        opts = {
          fast_wrap = {},
          disable_filetype = { 'TelescopePrompt', 'vim' },
        },
        config = function(_, opts)
          require('nvim-autopairs').setup(opts)

          -- setup cmp for autopairs
          local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
          require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end,
      },

      -- cmp sources plugins
      {
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
      },
    },
    opts = function()
      return require 'plugins.configs.cmp'
    end,
    config = function(_, opts)
      require('cmp').setup(opts)
    end,
  },

  {
    'numToStr/Comment.nvim',
    keys = {
      { 'gcc', mode = 'n', desc = 'Comment toggle current line' },
      { 'gc', mode = { 'n', 'o' }, desc = 'Comment toggle linewise' },
      { 'gc', mode = 'x', desc = 'Comment toggle linewise (visual)' },
      { 'gbc', mode = 'n', desc = 'Comment toggle current block' },
      { 'gb', mode = { 'n', 'o' }, desc = 'Comment toggle blockwise' },
      { 'gb', mode = 'x', desc = 'Comment toggle blockwise (visual)' },
    },
    init = function()
      require('core.utils').load_mappings 'comment'
    end,
    config = function(_, opts)
      require('Comment').setup(opts)
    end,
  },

  -- file managing , picker etc
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    init = function()
      require('core.utils').load_mappings 'nvimtree'
    end,
    opts = function()
      return require 'plugins.configs.nvimtree'
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'nvimtree')
      require('nvim-tree').setup(opts)
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cmd = 'Telescope',
    init = function()
      require('core.utils').load_mappings 'telescope'
    end,
    opts = function()
      return require 'plugins.configs.telescope'
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'telescope')
      local telescope = require 'telescope'
      telescope.setup(opts)

      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end
    end,
  },

  -- Only load whichkey after all the gui
  {
    'folke/which-key.nvim',
    keys = { '<leader>', '<c-r>', '<c-w>', '"', '\'', '`', 'c', 'v', 'g' },
    init = function()
      require('core.utils').load_mappings 'whichkey'
    end,
    cmd = 'WhichKey',
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'whichkey')
      require('which-key').setup(opts)
    end,
  },

  -- Github Copilot: AI Assistant
  {
    'github/copilot.vim',
    cmd = 'Copilot',
    lazy = false,
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.tab_fallback = ''
      vim.g.copilot_enabled = true
      vim.g.copilot_filetypes = {
        yaml = true,
        json = true,
        yml = true,
      }
    end,
  },

  -- Goto Preview: Preview Windows
  {
    'rmagatti/goto-preview',
    keys = { '<leader>' },
    init = function()
      require('core.utils').load_mappings 'goto_preview'
    end,
    config = function()
      require('goto-preview').setup {
        height = 20,
        width = 80,
      }
    end,
  },

  -- Harpoon: Fast File Navigation
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = { '<leader>', '<C-n>', '<C-p>' },
    lazy = false,
    init = function()
      local harpoon = require 'harpoon'
      harpoon:setup {
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      }

      require('core.utils').load_mappings 'harpoon'

      -- Open files marked with harpoon on startup
      if vim.fn.argc() == 0 then
        local files = harpoon:list()

        for _, file in ipairs(files.items) do
          vim.cmd('e ' .. file.value) -- I prefer the old "filename" but ok
          vim.fn.cursor(file.context.row, file.context.col)
        end
      end
    end,
  },

  -- Fugitive: Git Functions
  {
    'tpope/vim-fugitive',
    cmd = { 'Git' },
  },

  -- Git Blame in Virtual Text
  {
    'APZelos/blamer.nvim',
    lazy = false,
    config = function()
      vim.g.blamer_enabled = 1
    end,
  },

  -- Git Linker: Generate Git Permalinks
  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
    config = function()
      -- FIXME: Because of the way we set up the mapping in gitlinker, it will not
      -- show up within the whichkey menu (which is fine by me for now)
      require('gitlinker').setup {}
    end,
  },

  -- UFO: Code Folding
  {
    'kevinhwang91/nvim-ufo',
    -- keys = { 'za', 'zm', 'zM', 'zr', 'zR' },
    dependencies = {
      'kevinhwang91/promise-async',
      'neovim/nvim-lspconfig',
    },
    lazy = false,
    config = function()
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require('ufo').setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },

  -- Todo Comments: Highlight and Anchor Todos
  {
    'folke/todo-comments.nvim',
    event = 'BufRead', -- Highlight on BufRead
    lazy = false,
    -- TODO: Look into todo-comments options from NvPunk, I'm pretty sure it was
    -- just defaults, but maybe we can add new things
    config = function()
      require('todo-comments').setup()
    end,
  },

  -- Fidget: LSP Status indicator
  {
    'j-hui/fidget.nvim',
    tag = 'legacy', -- TODO: Remove legacy once migrated
    lazy = false,
    config = function()
      require('fidget').setup {
        text = {
          spinner = 'dots',
        },
        align = {
          bottom = true,
          right = true,
        },
      }
    end,
  },

  -- Undo Tree
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle' },
    init = function()
      require('core.utils').load_mappings 'undotree'
    end,
  },

  -- None LS: Null LS Fork that is actively maintained
  {
    'nvimtools/none-ls.nvim',
    lazy = false,
    config = function()
      local null_ls = require 'null-ls'
      local formatting = null_ls.builtins.formatting
      -- local diagnostics = null_ls.builtins.diagnostics
      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

      null_ls.setup {
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

        on_init = function(new_client, _)
          -- new_client.offset_encoding = 'utf-8' -- FIXME: This messed a lot of shit up
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
    end,
  },

  -- Mason Null LS: Bridge Mason and Null LS
  {
    'jay-babu/mason-null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'nvimtools/none-ls.nvim',
    },
    config = function()
      local masons_null_ls = require 'mason-null-ls'
      masons_null_ls.setup {
        ensure_installed = {
          'stylua',
          'prettier',
          'alex',
          'gofmt',
          -- 'rustfmt',
          'gofumpt',
        },
      }
    end,
  },

  -- Mason LSPConfig : Bridge Mason and LSPConfig
  {
    'williamboman/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = {
          'bashls',
          'dockerls',
          'gopls',
          'html',
          'jsonls',
          'pyright',
          'rust_analyzer',
          'tsserver',
          'vimls',
        },
      }
    end,
  },

  -- LSP Signature: Signature Help
  {
    'ray-x/lsp_signature.nvim',
    event = 'BufRead',
    lazy = false,
    config = function()
      require('lsp_signature').setup()
    end,
  },

  -- Trouble: Diagnostics Tray
  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    init = function()
      require('core.utils').load_mappings 'trouble'
    end,
    config = function()
      require('trouble').setup {
        position = 'bottom',
        icons = true,
        action_keys = {
          close = 'q', -- close the list
          cancel = '<esc>', -- cancel the preview and get back to your last window / buffer / cursor
          refresh = 'r', -- manually refresh
          jump = '<cr>', -- jump to the diagnostic or open / close fold's
          open_split = { 'i' }, -- open buffer in new split
          open_vsplit = { 's' }, -- open buffer in new vsplit
          open_tab = { 't' }, -- open buffer in new tab
          jump_close = { 'o' }, -- jump to the diagnostic and close the list
          toggle_mode = 'm', -- toggle between 'workspace' and 'document' diagnostics mode
          toggle_preview = 'P', -- toggle auto_preview
          hover = 'K', -- opens a small popup with the full multiline message
          preview = 'p', -- preview the diagnostic location
          close_folds = { 'zM', 'zm' }, -- close all folds
          open_folds = { 'zR', 'zr' }, -- open all folds
          toggle_fold = { 'zA', 'za' }, -- toggle fold of current file
          previous = 'k', -- preview item
          next = 'j', -- next item
        },
        use_diagnostic_signs = true,
      }
    end,
  },

  -- BQF: Better Quick Fix Tray
  {
    'kevinhwang91/nvim-bqf',
    lazy = false,
    config = function()
      require('bqf').setup {
        auto_enable = true,
        func_map = {
          tab = 't',
          split = 'i',
          vsplit = 's',
        },
      }
    end,
  },

  -- nvim-treessitter-context : Sticky Scroll
  {
    'nvim-treesitter/nvim-treesitter-context',
    lazy = false,
    init = function()
      require('core.utils').load_mappings 'treesitter_context'
    end,
    config = function()
      require('treesitter-context').setup {}
      vim.cmd [[TSContextEnable]]
    end,
  },

  -- RapidReturn: Stack Based Jumps
  {
    'RamitGoolry/RapidReturn',
    depends = { 'nvim-telescope/telescope.nvim' },
    lazy = false,
    init = function()
      require('core.utils').load_mappings 'rapidreturn'
    end,
  },

  -- LSP Saga: LSP UI
  {
    'nvimdev/lspsaga.nvim',
    lazy = false,
    init = function()
      require('core.utils').load_mappings 'lspsaga'
    end,
    config = function()
      require('lspsaga').setup {}
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  },

  {
    'towolf/vim-helm',
    ft = 'helm',
  },

  -- vim graphql
  {
    'jparise/vim-graphql',
    event = 'BufRead',
  },

  -- Conflict
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    config = true,
    lazy = false,
    dependencies = {
      'https://gitlab.com/yorickpeterse/nvim-pqf.git',
    },
  },

  -- Notify
  {
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      vim.notify = require 'notify'
    end,
  },

  -- Telescope Select UI
  {
    'nvim-telescope/telescope-ui-select.nvim',
    lazy = false,
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('telescope').load_extension 'ui-select'
    end,
  },

  -- DAP
  {
    'mfussenegger/nvim-dap',
    lazy = false,
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local dap_go = require 'dap-go'

      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸' },
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              'breakpoints',
              'stacks',
              'watches',
            },
            size = 35, -- 40 columns
            position = 'left',
          },
          {
            elements = {
              'scopes',
            },
            size = 0.35,
            position = 'right',
          },

          {
            elements = {
              'repl',
              'console',
            },
            size = 0.25, -- 25% of total lines
            position = 'bottom',
          },
        },
      }
      dap_go.setup()

      -- DAP UI Hooks: Open and Close on appropriate DAP Events
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },

  -- NVIM DAP Virtual Text
  {
    'theHamsta/nvim-dap-virtual-text',
    lazy = false,
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      require('nvim-dap-virtual-text').setup()
    end,
  },

  {
    'David-Kunz/gen.nvim',
    cmd = { 'Gen' },
    config = function()
      local gen = require 'gen'
      gen.setup {
        model = 'llama3',
        host = 'localhost',
        port = '11434',
        quit_map = 'q',
        retry_map = '<C-r>',
        init = function(options)
          pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
        end,
        command = function(options)
          local body = {
            model = options.model,
            stream = true,
          }
          return 'curl --silent --no-buffer -X POST http://'
            .. options.host
            .. ':'
            .. options.port
            .. '/api/chat -d $body'
        end,
        display_mode = 'float',
        show_prompt = false,
        show_nodel = false,
        no_auto_close = false,
        debug = false,
      }
    end,
  },

  -- Dadbod: UI for Databases
  {
    'tpope/vim-dadbod',
    cmd = { 'DB', 'DBUI' },
    dependencies = {
      'kristijanhusak/vim-dadbod-ui',
      'kristijanhusak/vim-dadbod-completion',
      'hrsh7th/nvim-cmp',
    },
    config = function()
      local cmp = require 'cmp'
      cmp.setup.filetype({ 'mysql' }, {
        sources = {
          { name = 'vim-dadbod-completion' },
          { name = 'buffer' },
        },
      })
    end,
  },
}

local config = require('core.utils').load_config()

if #config.plugins > 0 then
  table.insert(default_plugins, { import = config.plugins })
end

require('lazy').setup(default_plugins, config.lazy_nvim)
