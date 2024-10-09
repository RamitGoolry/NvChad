-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local default_plugins = {
  -- Plenary: Utility functions for literally everything
  { 'nvim-lua/plenary.nvim' },

  -- Base46: Theme plugin with caching
  {
    'NvChad/base46',
    branch = 'v2.0',
    lazy = false,
    build = function()
      require('base46').load_all_highlights()
    end,
  },

  -- UI: UI Plugin
  {
    'NvChad/ui',
    branch = 'v2.0',
    lazy = false,
  },

  -- NvTerm: Terminal Plugin
  {
    'NvChad/nvterm',
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'nvterm'
    end,
    config = function(_, opts)
      local _ = require 'base46.term'
      local nvterm = require 'nvterm'
      nvterm.setup(opts)
    end,
  },

  -- Colorizer: Colorizer Plugin
  {
    'NvChad/nvim-colorizer.lua',
    init = function()
      local utils = require 'core.utils'
      utils.lazy_load 'nvim-colorizer.lua'
    end,
    config = function(_, opts)
      local colorizer = require 'colorizer'
      colorizer.setup(opts)

      -- execute colorizer as soon as possible
      vim.defer_fn(function()
        colorizer.attach_to_buffer(0)
      end, 0)
    end,
  },

  -- Web Dev Icons: Icons for LSP
  {
    'nvim-tree/nvim-web-devicons',
    opts = function()
      local devicons = require 'nvchad.icons.devicons'
      return { override = devicons }
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'devicons')

      local nvim_web_devicons = require 'nvim-web-devicons'
      nvim_web_devicons.setup(opts)
    end,
  },

  -- Indent Blankline: Indentation Lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    version = '2.20.7',
    init = function()
      local utils = require 'core.utils'
      utils.lazy_load 'indent-blankline.nvim'
    end,
    opts = function()
      local others = require 'plugins.configs.others'
      return others.blankline
    end,
    config = function(_, opts)
      local utils = require 'core.utils'
      local indent_blankline = require 'indent_blankline'

      utils.load_mappings 'blankline'
      dofile(vim.g.base46_cache .. 'blankline')
      indent_blankline.setup(opts)
    end,
  },

  -- Treesitter: Syntax Highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    init = function()
      local utils = require 'core.utils'
      utils.lazy_load 'nvim-treesitter'
    end,
    cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    build = ':TSUpdate',
    opts = function()
      local treesitter = require 'plugins.configs.treesitter'
      return treesitter
    end,
    config = function(_, opts)
      local configs = require 'nvim-treesitter.configs'
      dofile(vim.g.base46_cache .. 'syntax')
      configs.setup(opts)
    end,
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    ft = { 'gitcommit', 'diff' },
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd({ 'BufRead' }, {
        group = vim.api.nvim_create_augroup('GitSignsLazyLoad', { clear = true }),
        callback = function()
          vim.fn.jobstart({ 'git', '-C', vim.uv.cwd(), 'rev-parse' }, {
            on_exit = function(_, return_code)
              if return_code == 0 then
                vim.api.nvim_del_augroup_by_name 'GitSignsLazyLoad'
                vim.schedule(function()
                  local lazy = require 'lazy'
                  lazy.load { plugins = { 'gitsigns.nvim' } }
                end)
              end
            end,
          })
        end,
      })
    end,
    opts = function()
      local others = require 'plugins.configs.others'
      return others.gitsigns
    end,
    config = function(_, opts)
      local gitsigns = require 'gitsigns'
      dofile(vim.g.base46_cache .. 'git')
      gitsigns.setup(opts)
    end,
  },

  -- Mason: LSP Binary Management
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonInstallAll', 'MasonUpdate' },
    opts = function()
      local mason = require 'plugins.configs.mason'
      return mason
    end,
    config = function(_, opts)
      local mason = require 'mason'
      dofile(vim.g.base46_cache .. 'mason')
      mason.setup(opts)

      -- custom nvchad cmd to install all mason binaries listed
      vim.api.nvim_create_user_command('MasonInstallAll', function()
        if opts.ensure_installed and #opts.ensure_installed > 0 then
          vim.cmd('MasonInstall ' .. table.concat(opts.ensure_installed, ' '))
        end
      end, {})

      vim.g.mason_binaries_list = opts.ensure_installed
    end,
  },

  -- LSPConfig: LSP Configuration
  {
    'neovim/nvim-lspconfig',
    init = function()
      local utils = require 'core.utils'
      utils.lazy_load 'nvim-lspconfig'
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
          local luasnip = require 'plugins.configs.luasnip'
          luasnip.load(opts)
        end,
      },

      -- autopairing of (){}[] etc
      {
        'windwp/nvim-autopairs',
        opts = {
          fast_wrap = {},
        },
        config = function(_, opts)
          local nvim_autopairs = require 'nvim-autopairs'
          -- TODO:(ramit) Fix the 'require' luasnip snippet. This should have been 'autopairs', not 'nvim_autopairs'
          nvim_autopairs.setup(opts)

          -- setup cmp for autopairs
          local cmp = require 'cmp'
          local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
          cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
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
      local cmp = require 'plugins.configs.cmp'
      return cmp
    end,
    config = function(_, opts)
      local cmp = require 'cmp'
      cmp.setup(opts)
    end,
  },

  {
    'echasnovski/mini.comment',
    version = '*', -- Stable Release
    event = 'BufRead',
    config = function()
      local comment = require 'mini.comment'
      comment.setup {
        -- Options which control module behavior
        options = {
          custom_commentstring = nil,
          ignore_blank_line = false,
          start_of_line = false,
          pad_comment_parts = true,
        },

        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          comment = '<leader>/',
          comment_line = '<leader>/',
          comment_visual = '<leader>/',

          -- Define 'comment' textobject (like `d//` - delete whole comment block)
          textobject = '//',
        },

        -- Hook functions to be executed at certain stage of commenting
        hooks = {
          pre = function() end,
          post = function() end,
        },
      }
    end,
  },

  -- file managing , picker etc
  -- TODO Remove this in favour of Oil as file opener
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'nvimtree'
    end,
    opts = function()
      local nvimtree = require 'plugins.configs.nvimtree'
      return nvimtree
    end,
    config = function(_, opts)
      local nvim_tree = require 'nvim-tree'
      dofile(vim.g.base46_cache .. 'nvimtree')
      nvim_tree.setup(opts)
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = '^1.0.0',
      },
    },
    cmd = 'Telescope',
    lazy = false,
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'telescope'
    end,
    opts = function()
      local telescope = require 'plugins.configs.telescope'
      return telescope
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
      local utils = require 'core.utils'
      utils.load_mappings 'whichkey'
    end,
    cmd = 'WhichKey',
    config = function(_, opts)
      local which_key = require 'which-key'
      dofile(vim.g.base46_cache .. 'whichkey')
      which_key.setup(opts)
    end,
  },

  -- Supermaven: AI Assistant
  {
    'supermaven-inc/supermaven-nvim',
    lazy = false,
    config = function()
      local supermaven_nvim = require 'supermaven-nvim'
      supermaven_nvim.setup {
        keymaps = {
          accept_suggestion = '<S-Tab>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-j>',
        },
        ignore_filetypes = {},
      }
    end,
  },

  -- Goto Preview: Preview Windows
  {
    'rmagatti/goto-preview',
    event = 'VeryLazy',
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'goto_preview'
    end,
    config = function()
      local goto_preview = require 'goto-preview'
      goto_preview.setup {
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

      local utils = require 'core.utils'
      utils.load_mappings 'harpoon'
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
      -- NOTE: Because of the way we set up the mapping in gitlinker, it will not
      -- show up within the whichkey menu (which is fine by me for now)
      local gitlinker = require 'gitlinker'
      gitlinker.setup {}
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

      local ufo = require 'ufo'

      ufo.setup {
        provider_selector = function(_, _, _)
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
    config = function()
      local opts = {
        signs = true, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- keywords recognized as todo comments
        keywords = {
          FIX = {
            icon = ' ', -- icon used for the sign, and in search results
            color = 'error', -- can be a hex color, or a named color (see below)
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
          },
          TODO = { icon = ' ', color = 'info' },
          HACK = { icon = ' ', color = 'warning' },
          WARN = { icon = ' ', color = 'warning' },
          PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
          NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
          TEST = {
            icon = '⏲ ',
            color = 'test',
            alt = { 'TESTING', 'PASSED', 'FAILED' },
          },
          REMOVE = {
            icon = ' ',
            color = '#ff0000',
            alt = { 'DELETE', 'REMOVE', 'CLEAN', 'REVERT' },
          },
        },
        gui_style = {
          fg = 'NONE', -- The gui style to use for the fg highlight group.
          bg = 'BOLD', -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
          multiline = true, -- enable multine todo comments
          multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
          multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
          before = '', -- "fg" or "bg" or empty
          keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
          after = 'fg', -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
          comments_only = true, -- uses treesitter to match keywords in comments only
          max_line_len = 400, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of highlight groups or use the hex color if hl not found as a fallback
        colors = {
          error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
          warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
          info = { 'DiagnosticInfo', '#2563EB' },
          hint = { 'DiagnosticHint', '#10B981' },
          default = { 'Identifier', '#7C3AED' },
          test = { 'Identifier', '#FF00FF' },
        },
        search = {
          command = 'rg',
          args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
          },
          -- regex that will be used to match keywords.
          -- don't replace the (KEYWORDS) placeholder
          pattern = [[\b(KEYWORDS):]], -- ripgrep regex
          -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
        },
      }

      local todo_comments = require 'todo-comments'
      todo_comments.setup { opts }
    end,
  },

  -- Fidget: LSP Status indicator
  {
    'j-hui/fidget.nvim',
    lazy = false,
    config = function()
      local fidget = require 'fidget'
      fidget.setup {
        progress = {
          lsp = {
            progress_ringbuf_size = 2048,
          },
        },
      }
    end,
  },

  -- Undo Tree
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle' },
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'undotree'
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
          'prettierd',
          'alex',
          'gofmt',
          -- 'rustfmt', -- rustfmt has been deprecated from Mason
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
          'ts_ls',
          'basedpyright',
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
      local lsp_signature = require 'lsp_signature'
      lsp_signature.setup()
    end,
  },

  -- Trouble: Diagnostics Tray
  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'trouble'
    end,
    config = function()
      local trouble = require 'trouble'
      trouble.setup {
        -- position = 'bottom',
        -- icons = true,
        -- action_keys = {
        --   close = 'q',
        --   cancel = '<esc>',
        --   refresh = 'r',
        --   jump = '<cr>',
        --   open_split = { 'i' },
        --   open_vsplit = { 's' },
        --   open_tab = { 't' },
        --   jump_close = { 'o' },
        --   toggle_mode = 'm',
        --   toggle_preview = 'P',
        --   hover = 'K',
        --   preview = 'p',
        --   close_folds = { 'zM', 'zm' },
        --   open_folds = { 'zR', 'zr' },
        --   toggle_fold = { 'zA', 'za' },
        --   previous = 'k',
        --   next = 'j',
        -- },
        -- use_diagnostic_signs = true,
      }
    end,
  },

  -- BQF: Better Quick Fix Tray
  {
    'kevinhwang91/nvim-bqf',
    lazy = false,
    config = function()
      local bqf = require 'bqf'
      bqf.setup {
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
      local treesitter_context = require 'treesitter-context'
      treesitter_context.setup {
        enable = false,
      }
      vim.cmd [[TSContextEnable]]
    end,
  },

  -- RapidReturn: Stack Based Jumps
  {
    'RamitGoolry/RapidReturn',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    lazy = false,
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'rapidreturn'
    end,
  },

  -- LSP Saga: LSP UI
  {
    'nvimdev/lspsaga.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    lazy = false,
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'lspsaga'
    end,
    config = function()
      local lspsaga = require 'lspsaga'
      lspsaga.setup {}
    end,
  },

  -- Helm LSP Server
  {
    'towolf/vim-helm',
    lazy = false,
  },

  -- GraphQL
  {
    'jparise/vim-graphql',
    event = 'BufRead',
  },

  -- Notification Plugin
  {
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      local notify = require 'notify'
      vim.notify = notify
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
      local telescope = require 'telescope'
      telescope.load_extension 'ui-select'
    end,
  },

  -- DAP: Debugger Plugin
  {
    'mfussenegger/nvim-dap',
    lazy = false,
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'plugins.configs.dap'
      dap.config()
    end,
  },

  -- NVIM DAP Virtual Text: Shows valus of variables in the current scope in virtual text
  {
    'theHamsta/nvim-dap-virtual-text',
    lazy = false,
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      local nvim_dap_virtual_text = require 'nvim-dap-virtual-text'
      nvim_dap_virtual_text.setup()
    end,
  },

  -- Gen: AI Assistant using Ollama
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
        init = function(_)
          pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
        end,
        command = function(options)
          local _ = {
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

  -- Oil: Directory Viewer / Manager
  {
    'stevearc/oil.nvim',
    cmd = { 'Oil' },
    config = function()
      local oil = require 'oil'
      oil.setup {
        delete_to_trash = true, -- to be safe for now
        skip_confirm_for_simple_edits = true,
      }
    end,
  },

  -- XBase: Basics for XCode Development
  {
    'xbase-lab/xbase',
    build = 'make install',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    lazy = false, -- NOTE: For now
    -- ft = { 'objc', 'swift' },
    config = function()
      local xbase = require 'xbase'
      local _ = require 'xbase.statusline'
      xbase.setup {
        --- Log level. Set it to ERROR to ignore everything
        log_level = vim.log.levels.DEBUG,
        statusline = {
          watching = { icon = '', color = '#1abc9c' },
          device_running = { icon = '', color = '#4a6edb' },
          success = { icon = '', color = '#1abc9c' },
          failure = { icon = '', color = '#db4b4b' },
        },
        simctl = { -- {} = all available devices
          iOS = {},
          watchOS = {},
          tvOS = {},
          visionOS = {},
        },
        log_buffer = {
          focus = true,
          height = 20,
          width = 75,
          default_direction = 'horizontal',
        },
        mappings = {
          enable = true,
          build_picker = '<leader>xb',
          run_picker = '<leader>xr',
          watch_picker = '<leader>xs',
          all_picker = '<leader>xa',
          toggle_split_log_buffer = '<leader>x"',
          toggle_vsplit_log_buffer = '<leader>%',
        },
      }
      -- statusline.feline()
    end,
  },

  -- SchemaStore: Schema Store for JSON
  -- TODO: Maybe we don't need this
  {
    'b0o/schemastore.nvim',
  },

  -- Flash: Fast File Navigation
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'flash'
    end,
    config = function()
      local flash = require 'flash'
      flash.setup()
    end,
  },

  -- Noice: Better vim UI
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
      'hrsh7th/nvim-cmp',
    },
    event = 'VeryLazy',
    config = function()
      local noice = require 'noice'
      noice.setup {
        messages = { enabled = false },
        notify = { enabled = false },
        lsp = {
          progress = { enabled = false },
          signature = { enabled = false },
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        presets = {
          bottom_search = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      }
    end,
  },

  -- Twilight: Focus Mode
  {
    'folke/twilight.nvim',
    event = 'BufReadPost',
  },

  -- Prettier for JS/TS
  {
    'MunifTanjim/prettier.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvimtools/none-ls.nvim',
    },
    lazy = false,
    config = function()
      local null_ls = require 'null-ls'
      local group = vim.api.nvim_create_augroup('lsp_format_on_save', {
        clear = false,
      })

      local event = 'BufWritePre'
      local async = event == 'BufWritePost'

      -- Setup for null ls
      null_ls.setup {
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            -- format on save
            vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
            vim.api.nvim_create_autocmd(event, {
              buffer = bufnr,
              group = group,
              callback = function()
                vim.lsp.buf.format { bufnr = bufnr, async = async }
              end,
              desc = '[prettier] format on save',
            })
          end
        end,
      }

      local prettier = require 'prettier'
      prettier.setup {
        bin = 'prettier', -- or `'prettierd'` (v0.23.3+)
        filetypes = {
          'css',
          'html',
          'javascript',
          'javascriptreact',
          'json',
          'less',
          'markdown',
          'scss',
          'typescript',
          'typescriptreact',
        },
      }
    end,
  },

  -- Sleuth: Auto Indent Detection
  {
    'tpope/vim-sleuth',
    event = 'BufRead',
  },

  -- Precognition: Vim motions practice
  {
    'tris203/precognition.nvim',
    event = 'VeryLazy',
    config = {
      startVisible = false,
      showBlankVirtLine = true,
      highlightColor = { link = 'String' },
      hints = {
        Caret = { text = '^', prio = 2 },
        Dollar = { text = '$', prio = 1 },
        MatchingPair = { text = '%', prio = 5 },
        Zero = { text = '0', prio = 1 },
        w = { text = 'w', prio = 10 },
        b = { text = 'b', prio = 9 },
        e = { text = 'e', prio = 8 },
        W = { text = 'W', prio = 7 },
        B = { text = 'B', prio = 6 },
        E = { text = 'E', prio = 5 },
      },
      gutterHints = {
        G = { text = 'G', prio = 10 },
        gg = { text = 'gg', prio = 9 },
        PrevParagraph = { text = '{', prio = 8 },
        NextParagraph = { text = '}', prio = 8 },
      },
    },
  },

  -- Persisted: Session Persistence
  {
    'olimorris/persisted.nvim',
    lazy = false, -- make sure the plugin is always loaded at startup
    config = function()
      local persisted = require 'persisted'
      persisted.setup {
        save_dir = vim.fn.expand(vim.fn.stdpath 'data' .. '/sessions/'), -- directory where session files are saved
        silent = false, -- silent nvim message when sourcing session file
        use_git_branch = true, -- create session files based on the branch of a git enabled repository
        default_branch = 'master', -- the branch to load if a session file is not found for the current branch
        autosave = true, -- automatically save session files when exiting Neovim
        should_autosave = nil, -- function to determine if a session should be autosaved
        autoload = true, -- automatically load the session for the cwd on Neovim startup
        on_autoload_no_session = nil, -- function to run when `autoload = true` but there is no session to load
        follow_cwd = true, -- change session file name to match current working directory if it changes
        allowed_dirs = nil, -- table of dirs that the plugin will auto-save and auto-load from
        ignored_dirs = nil, -- table of dirs that are ignored when auto-saving and auto-loading
        ignored_branches = nil, -- table of branch patterns that are ignored for auto-saving and auto-loading
        telescope = {
          reset_prompt = true, -- Reset the Telescope prompt after an action?
          mappings = { -- table of mappings for the Telescope extension
            change_branch = '<c-b>',
            copy_session = '<c-c>',
            delete_session = '<c-d>',
          },
          icons = { -- icons displayed in the picker, set to nil to disable entirely
            branch = ' ',
            dir = ' ',
            selected = ' ',
          },
        },
      }
    end,
  },

  -- Neotest: Testing library
  -- TODO: This needs to be better for me to actualy use it. How can I have auto testing for golang?
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'fredrikaverpil/neotest-golang',
    },

    init = function()
      local utils = require 'core.utils'
      utils.load_mappings 'neotest'
    end,

    config = function()
      local neotest = require 'neotest'
      local neotest_golang = require 'neotest-golang'

      local go_test_config = {
        go_test_args = {
          '-v',
          '-count=1',
          '-timeout=10s',
          '-parallel=6',
        },
        dap_go_enabled = true,
      }

      neotest.setup {
        adapters = {
          neotest_golang(go_test_config),
        },
      }
    end,
  },

  -- Mini Scrollbar Plugin: Highlights errors and warnings without intruding at all
  {
    'petertriho/nvim-scrollbar',
    lazy = false,
    config = function()
      local scrollbar = require 'scrollbar'
      scrollbar.setup()
    end,
  },

  -- Kubectl: Kubernetes Plugin
  -- TODO: I don't know how to use this, I'm not sure if I want to use it
  {
    'ramilito/kubectl.nvim',
    event = 'VeryLazy',
    config = function()
      local kubectl = require 'kubectl'
      kubectl.setup()
    end,
  },

  -- Diffview: Diff View Plugin
  {
    'sindrets/diffview.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    event = 'VeryLazy',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles' },
    config = function()
      local diffview = require 'diffview'
      local actions = require 'diffview.actions'
      diffview.setup {
        diff_binaries = false, -- Show diffs for binaries
        enhanced_diff_hl = false, -- See |diffview-config-enhanced_diff_hl|
        git_cmd = { 'git' }, -- The git executable followed by default args.
        hg_cmd = { 'hg' }, -- The hg executable followed by default args.
        use_icons = true, -- Requires nvim-web-devicons
        show_help_hints = true, -- Show hints for how to open the help panel
        watch_index = true, -- Update views and index buffers when the git index changes.
        icons = { -- Only applies when use_icons is true.
          folder_closed = '',
          folder_open = '',
        },
        signs = {
          fold_closed = '',
          fold_open = '',
          done = '✓',
        },
        view = {
          -- Configure the layout and behavior of different types of views.
          -- Available layouts:
          --  'diff1_plain'
          --    |'diff2_horizontal'
          --    |'diff2_vertical'
          --    |'diff3_horizontal'
          --    |'diff3_vertical'
          --    |'diff3_mixed'
          --    |'diff4_mixed'
          -- For more info, see |diffview-config-view.x.layout|.
          default = {
            -- Config for changed files, and staged files in diff views.
            layout = 'diff2_horizontal',
            disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
            winbar_info = false, -- See |diffview-config-view.x.winbar_info|
          },
          merge_tool = {
            -- Config for conflicted files in diff views during a merge or rebase.
            layout = 'diff3_horizontal',
            disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
            winbar_info = true, -- See |diffview-config-view.x.winbar_info|
          },
          file_history = {
            -- Config for changed files in file history views.
            layout = 'diff2_horizontal',
            disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
            winbar_info = false, -- See |diffview-config-view.x.winbar_info|
          },
        },
        file_panel = {
          listing_style = 'tree', -- One of 'list' or 'tree'
          tree_options = { -- Only applies when listing_style is 'tree'
            flatten_dirs = true, -- Flatten dirs that only contain one single dir
            folder_statuses = 'only_folded', -- One of 'never', 'only_folded' or 'always'.
          },
          win_config = { -- See |diffview-config-win_config|
            position = 'left',
            width = 35,
            win_opts = {},
          },
        },
        file_history_panel = {
          log_options = { -- See |diffview-config-log_options|
            git = {
              single_file = {
                diff_merges = 'combined',
              },
              multi_file = {
                diff_merges = 'first-parent',
              },
            },
            hg = {
              single_file = {},
              multi_file = {},
            },
          },
          win_config = { -- See |diffview-config-win_config|
            position = 'bottom',
            height = 16,
            win_opts = {},
          },
        },
        commit_log_panel = {
          win_config = {}, -- See |diffview-config-win_config|
        },
        default_args = { -- Default args prepended to the arg-list for the listed commands
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {}, -- See |diffview-config-hooks|
        keymaps = {
          disable_defaults = false, -- Disable the default keymaps
          view = {
            -- The `view` bindings are active in the diff buffers, only when the current
            -- tabpage is a Diffview.
            {
              'n',
              '<tab>',
              actions.select_next_entry,
              { desc = 'Open the diff for the next file' },
            },
            {
              'n',
              '<s-tab>',
              actions.select_prev_entry,
              { desc = 'Open the diff for the previous file' },
            },
            {
              'n',
              '[F',
              actions.select_first_entry,
              { desc = 'Open the diff for the first file' },
            },
            {
              'n',
              ']F',
              actions.select_last_entry,
              { desc = 'Open the diff for the last file' },
            },
            {
              'n',
              'gf',
              actions.goto_file_edit,
              { desc = 'Open the file in the previous tabpage' },
            },
            {
              'n',
              '<C-w><C-f>',
              actions.goto_file_split,
              { desc = 'Open the file in a new split' },
            },
            {
              'n',
              '<C-w>gf',
              actions.goto_file_tab,
              { desc = 'Open the file in a new tabpage' },
            },
            {
              'n',
              '<leader>e',
              actions.focus_files,
              { desc = 'Bring focus to the file panel' },
            },
            {
              'n',
              '<leader>b',
              actions.toggle_files,
              { desc = 'Toggle the file panel.' },
            },
            {
              'n',
              'g<C-x>',
              actions.cycle_layout,
              { desc = 'Cycle through available layouts.' },
            },
            {
              'n',
              '[x',
              actions.prev_conflict,
              { desc = 'In the merge-tool: jump to the previous conflict' },
            },
            {
              'n',
              ']x',
              actions.next_conflict,
              { desc = 'In the merge-tool: jump to the next conflict' },
            },
            {
              'n',
              '<leader>co',
              actions.conflict_choose 'ours',
              { desc = 'Choose the OURS version of a conflict' },
            },
            {
              'n',
              '<leader>ct',
              actions.conflict_choose 'theirs',
              { desc = 'Choose the THEIRS version of a conflict' },
            },
            {
              'n',
              '<leader>cb',
              actions.conflict_choose 'base',
              { desc = 'Choose the BASE version of a conflict' },
            },
            {
              'n',
              '<leader>ca',
              actions.conflict_choose 'all',
              { desc = 'Choose all the versions of a conflict' },
            },
            {
              'n',
              'dx',
              actions.conflict_choose 'none',
              { desc = 'Delete the conflict region' },
            },
            {
              'n',
              '<leader>cO',
              actions.conflict_choose_all 'ours',
              { desc = 'Choose the OURS version of a conflict for the whole file' },
            },
            {
              'n',
              '<leader>cT',
              actions.conflict_choose_all 'theirs',
              { desc = 'Choose the THEIRS version of a conflict for the whole file' },
            },
            {
              'n',
              '<leader>cB',
              actions.conflict_choose_all 'base',
              { desc = 'Choose the BASE version of a conflict for the whole file' },
            },
            {
              'n',
              '<leader>cA',
              actions.conflict_choose_all 'all',
              { desc = 'Choose all the versions of a conflict for the whole file' },
            },
            {
              'n',
              'dX',
              actions.conflict_choose_all 'none',
              { desc = 'Delete the conflict region for the whole file' },
            },
          },
          diff1 = {
            -- Mappings in single window diff layouts
            { 'n', 'g?', actions.help { 'view', 'diff1' }, { desc = 'Open the help panel' } },
          },
          diff2 = {
            -- Mappings in 2-way diff layouts
            { 'n', 'g?', actions.help { 'view', 'diff2' }, { desc = 'Open the help panel' } },
          },
          diff3 = {
            -- Mappings in 3-way diff layouts
            {
              { 'n', 'x' },
              '2do',
              actions.diffget 'ours',
              { desc = 'Obtain the diff hunk from the OURS version of the file' },
            },
            {
              { 'n', 'x' },
              '3do',
              actions.diffget 'theirs',
              { desc = 'Obtain the diff hunk from the THEIRS version of the file' },
            },
            {
              'n',
              'g?',
              actions.help { 'view', 'diff3' },
              { desc = 'Open the help panel' },
            },
          },
          diff4 = {
            -- Mappings in 4-way diff layouts
            {
              { 'n', 'x' },
              '1do',
              actions.diffget 'base',
              { desc = 'Obtain the diff hunk from the BASE version of the file' },
            },
            {
              { 'n', 'x' },
              '2do',
              actions.diffget 'ours',
              { desc = 'Obtain the diff hunk from the OURS version of the file' },
            },
            {
              { 'n', 'x' },
              '3do',
              actions.diffget 'theirs',
              { desc = 'Obtain the diff hunk from the THEIRS version of the file' },
            },
            {
              'n',
              'g?',
              actions.help { 'view', 'diff4' },
              { desc = 'Open the help panel' },
            },
          },
          file_panel = {
            {
              'n',
              'j',
              actions.next_entry,
              { desc = 'Bring the cursor to the next file entry' },
            },
            {
              'n',
              '<down>',
              actions.next_entry,
              { desc = 'Bring the cursor to the next file entry' },
            },
            {
              'n',
              'k',
              actions.prev_entry,
              { desc = 'Bring the cursor to the previous file entry' },
            },
            {
              'n',
              '<up>',
              actions.prev_entry,
              { desc = 'Bring the cursor to the previous file entry' },
            },
            {
              'n',
              '<cr>',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              'o',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              'l',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              '<2-LeftMouse>',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              '-',
              actions.toggle_stage_entry,
              { desc = 'Stage / unstage the selected entry' },
            },
            {
              'n',
              's',
              actions.toggle_stage_entry,
              { desc = 'Stage / unstage the selected entry' },
            },
            {
              'n',
              'S',
              actions.stage_all,
              { desc = 'Stage all entries' },
            },
            {
              'n',
              'U',
              actions.unstage_all,
              { desc = 'Unstage all entries' },
            },
            {
              'n',
              'X',
              actions.restore_entry,
              { desc = 'Restore entry to the state on the left side' },
            },
            {
              'n',
              'L',
              actions.open_commit_log,
              { desc = 'Open the commit log panel' },
            },
            {
              'n',
              'zo',
              actions.open_fold,
              { desc = 'Expand fold' },
            },
            {
              'n',
              'h',
              actions.close_fold,
              { desc = 'Collapse fold' },
            },
            {
              'n',
              'zc',
              actions.close_fold,
              { desc = 'Collapse fold' },
            },
            {
              'n',
              'za',
              actions.toggle_fold,
              { desc = 'Toggle fold' },
            },
            {
              'n',
              'zR',
              actions.open_all_folds,
              { desc = 'Expand all folds' },
            },
            {
              'n',
              'zM',
              actions.close_all_folds,
              { desc = 'Collapse all folds' },
            },
            {
              'n',
              '<c-b>',
              actions.scroll_view(-0.25),
              { desc = 'Scroll the view up' },
            },
            {
              'n',
              '<c-f>',
              actions.scroll_view(0.25),
              { desc = 'Scroll the view down' },
            },
            {
              'n',
              '<tab>',
              actions.select_next_entry,
              { desc = 'Open the diff for the next file' },
            },
            {
              'n',
              '<s-tab>',
              actions.select_prev_entry,
              { desc = 'Open the diff for the previous file' },
            },
            {
              'n',
              '[F',
              actions.select_first_entry,
              { desc = 'Open the diff for the first file' },
            },
            {
              'n',
              ']F',
              actions.select_last_entry,
              { desc = 'Open the diff for the last file' },
            },
            {
              'n',
              'gf',
              actions.goto_file_edit,
              { desc = 'Open the file in the previous tabpage' },
            },
            {
              'n',
              '<C-w><C-f>',
              actions.goto_file_split,
              { desc = 'Open the file in a new split' },
            },
            {
              'n',
              '<C-w>gf',
              actions.goto_file_tab,
              { desc = 'Open the file in a new tabpage' },
            },
            {
              'n',
              'i',
              actions.listing_style,
              { desc = 'Toggle between \'list\' and \'tree\' views' },
            },
            {
              'n',
              'f',
              actions.toggle_flatten_dirs,
              { desc = 'Flatten empty subdirectories in tree listing style' },
            },
            {
              'n',
              'R',
              actions.refresh_files,
              { desc = 'Update stats and entries in the file list' },
            },
            {
              'n',
              '<leader>e',
              actions.focus_files,
              { desc = 'Bring focus to the file panel' },
            },
            {
              'n',
              '<leader>b',
              actions.toggle_files,
              { desc = 'Toggle the file panel' },
            },
            {
              'n',
              'g<C-x>',
              actions.cycle_layout,
              { desc = 'Cycle available layouts' },
            },
            {
              'n',
              '[x',
              actions.prev_conflict,
              { desc = 'Go to the previous conflict' },
            },
            {
              'n',
              ']x',
              actions.next_conflict,
              { desc = 'Go to the next conflict' },
            },
            {
              'n',
              'g?',
              actions.help 'file_panel',
              { desc = 'Open the help panel' },
            },
            {
              'n',
              '<leader>cO',
              actions.conflict_choose_all 'ours',
              { desc = 'Choose the OURS version of a conflict for the whole file' },
            },
            {
              'n',
              '<leader>cT',
              actions.conflict_choose_all 'theirs',
              { desc = 'Choose the THEIRS version of a conflict for the whole file' },
            },
            {
              'n',
              '<leader>cB',
              actions.conflict_choose_all 'base',
              { desc = 'Choose the BASE version of a conflict for the whole file' },
            },
            {
              'n',
              '<leader>cA',
              actions.conflict_choose_all 'all',
              { desc = 'Choose all the versions of a conflict for the whole file' },
            },
            {
              'n',
              'dX',
              actions.conflict_choose_all 'none',
              { desc = 'Delete the conflict region for the whole file' },
            },
          },
          file_history_panel = {
            {
              'n',
              'g!',
              actions.options,
              { desc = 'Open the option panel' },
            },
            {
              'n',
              '<C-A-d>',
              actions.open_in_diffview,
              { desc = 'Open the entry under the cursor in a diffview' },
            },
            {
              'n',
              'y',
              actions.copy_hash,
              { desc = 'Copy the commit hash of the entry under the cursor' },
            },
            {
              'n',
              'L',
              actions.open_commit_log,
              { desc = 'Show commit details' },
            },
            {
              'n',
              'X',
              actions.restore_entry,
              { desc = 'Restore file to the state from the selected entry' },
            },
            { 'n', 'zo', actions.open_fold, { desc = 'Expand fold' } },
            {
              'n',
              'zc',
              actions.close_fold,
              { desc = 'Collapse fold' },
            },
            {
              'n',
              'h',
              actions.close_fold,
              { desc = 'Collapse fold' },
            },
            { 'n', 'za', actions.toggle_fold, { desc = 'Toggle fold' } },
            {
              'n',
              'zR',
              actions.open_all_folds,
              { desc = 'Expand all folds' },
            },
            {
              'n',
              'zM',
              actions.close_all_folds,
              { desc = 'Collapse all folds' },
            },
            {
              'n',
              'j',
              actions.next_entry,
              { desc = 'Bring the cursor to the next file entry' },
            },
            {
              'n',
              '<down>',
              actions.next_entry,
              { desc = 'Bring the cursor to the next file entry' },
            },
            {
              'n',
              'k',
              actions.prev_entry,
              { desc = 'Bring the cursor to the previous file entry' },
            },
            {
              'n',
              '<up>',
              actions.prev_entry,
              { desc = 'Bring the cursor to the previous file entry' },
            },
            {
              'n',
              '<cr>',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              'o',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              'l',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              '<2-LeftMouse>',
              actions.select_entry,
              { desc = 'Open the diff for the selected entry' },
            },
            {
              'n',
              '<c-b>',
              actions.scroll_view(-0.25),
              { desc = 'Scroll the view up' },
            },
            {
              'n',
              '<c-f>',
              actions.scroll_view(0.25),
              { desc = 'Scroll the view down' },
            },
            {
              'n',
              '<tab>',
              actions.select_next_entry,
              { desc = 'Open the diff for the next file' },
            },
            {
              'n',
              '<s-tab>',
              actions.select_prev_entry,
              { desc = 'Open the diff for the previous file' },
            },
            {
              'n',
              '[F',
              actions.select_first_entry,
              { desc = 'Open the diff for the first file' },
            },
            {
              'n',
              ']F',
              actions.select_last_entry,
              { desc = 'Open the diff for the last file' },
            },
            {
              'n',
              'gf',
              actions.goto_file_edit,
              { desc = 'Open the file in the previous tabpage' },
            },
            {
              'n',
              '<C-w><C-f>',
              actions.goto_file_split,
              { desc = 'Open the file in a new split' },
            },
            {
              'n',
              '<C-w>gf',
              actions.goto_file_tab,
              { desc = 'Open the file in a new tabpage' },
            },
            {
              'n',
              '<leader>e',
              actions.focus_files,
              { desc = 'Bring focus to the file panel' },
            },
            {
              'n',
              '<leader>b',
              actions.toggle_files,
              { desc = 'Toggle the file panel' },
            },
            {
              'n',
              'g<C-x>',
              actions.cycle_layout,
              { desc = 'Cycle available layouts' },
            },
            {
              'n',
              'g?',
              actions.help 'file_history_panel',
              { desc = 'Open the help panel' },
            },
          },
          option_panel = {
            { 'n', '<tab>', actions.select_entry, { desc = 'Change the current option' } },
            { 'n', 'q', actions.close, { desc = 'Close the panel' } },
            { 'n', 'g?', actions.help 'option_panel', { desc = 'Open the help panel' } },
          },
          help_panel = {
            { 'n', 'q', actions.close, { desc = 'Close help menu' } },
            { 'n', '<esc>', actions.close, { desc = 'Close help menu' } },
          },
        },
      }
    end,
  },
}

local config = require('core.utils').load_config()
if #config.plugins > 0 then
  table.insert(default_plugins, { import = config.plugins })
end

require('lazy').setup(default_plugins, config.lazy_nvim)
