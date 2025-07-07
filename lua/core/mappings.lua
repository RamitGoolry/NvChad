-- n, v, i, t = mode names

local exports = {}

exports.general = {
  n = {
    ['<Esc>'] = {
      function()
        vim.cmd [[noh]]
      end,
      'Clear highlights',
    },
    ['Q'] = { 'q', 'Quit' },
    -- switch between windows
    ['<C-h>'] = { '<C-w>h', 'Window left' },
    ['<C-l>'] = { '<C-w>l', 'Window right' },
    ['<C-j>'] = { '<C-w>j', 'Window down' },
    ['<C-k>'] = { '<C-w>k', 'Window up' },

    -- splitting windows
    ['<leader>%'] = {
      function()
        vim.cmd [[vsplit]]
      end,
      'Split Window Vertically',
    },
    ['<leader>"'] = {
      function()
        vim.cmd [[split]]
      end,
      'Split Window Horizontally',
    },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    ['j'] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 'Move down', opts = { expr = true } },
    ['k'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 'Move up', opts = { expr = true } },
    ['<Up>'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 'Move up', opts = { expr = true } },
    ['<Down>'] = {
      'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
      'Move down',
      opts = { expr = true },
    },

    ['<leader>ch'] = {
      function()
        vim.cmd [[NvCheatsheet]]
      end,
      'Mapping cheatsheet',
    },

    ['<leader>fm'] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      'LSP formatting',
    },
  },

  t = {
    ['<C-x>'] = {
      vim.api.nvim_replace_termcodes('<C-\\><C-N>', true, true, true),
      'Escape terminal mode',
    },
  },

  v = {
    ['<Up>'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 'Move up', opts = { expr = true } },
    ['<Down>'] = {
      'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
      'Move down',
      opts = { expr = true },
    },
    ['<'] = { '<gv', 'Indent line' },
    ['>'] = { '>gv', 'Indent line' },
  },

  x = {
    ['j'] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 'Move down', opts = { expr = true } },
    ['k'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 'Move up', opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    ['p'] = { 'p:let @+=@0<CR>:let @"=@0<CR>', 'Dont copy replaced text', opts = { silent = true } },
  },
}

exports.tabufline = {
  plugin = true,
}

exports.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    ['gD'] = {
      function()
        vim.lsp.buf.declaration()
      end,
      'LSP declaration',
    },

    ['gd'] = {
      function()
        vim.lsp.buf.definition()
      end,
      'LSP definition',
    },

    ['K'] = {
      function()
        vim.lsp.buf.hover()
      end,
      'LSP hover',
    },

    ['gi'] = {
      function()
        vim.lsp.buf.implementation()
      end,
      'LSP implementation',
    },

    ['<leader>ls'] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      'LSP signature help',
    },

    ['<leader>D'] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      'LSP definition type',
    },

    ['<leader>ra'] = {
      function()
        require('nvchad.renamer').open()
      end,
      'LSP rename',
    },

    ['gr'] = {
      function()
        vim.lsp.buf.references()
      end,
      'LSP references',
    },

    ['<leader>lf'] = {
      function()
        vim.diagnostic.open_float { border = 'rounded' }
      end,
      'Floating diagnostic',
    },

    ['[d'] = {
      function()
        vim.diagnostic.goto_prev { float = { border = 'rounded' } }
      end,
      'Goto prev',
    },

    [']d'] = {
      function()
        vim.diagnostic.goto_next { float = { border = 'rounded' } }
      end,
      'Goto next',
    },

    ['<leader>q'] = {
      function()
        vim.diagnostic.setloclist()
      end,
      'Diagnostic setloclist',
    },

    ['<leader>wa'] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      'Add workspace folder',
    },

    ['<leader>wr'] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      'Remove workspace folder',
    },

    ['<leader>wl'] = {
      function()
        local folders = vim.lsp.buf.list_workspace_folders()
        if #folders == 0 then
          vim.notify('No workspace folders', vim.log.levels.INFO)
        else
          vim.notify('Workspace folders:\n' .. table.concat(folders, '\n'), vim.log.levels.INFO)
        end
      end,
      'List workspace folders',
    },

    ['<leader>['] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      'Go to previous diagnostic',
    },

    ['<leader>]'] = {
      function()
        vim.diagnostic.goto_next()
      end,
      'Go to next diagnostic',
    },
  },

  v = {
    ['<leader>ca'] = {
      function()
        vim.lsp.buf.code_action()
      end,
      'LSP code action',
    },
  },
}

exports.nvimtree = {
  plugin = true,

  n = {},
}

exports.snacks = {
  plugin = true,

  n = {
    -- Lazygit
    ['<leader>lg'] = {
      function()
        local snacks = require 'snacks'
        snacks.lazygit.open()
      end,
      'Lazygit',
    },

    -- Picker
    ['<leader>ff'] = {
      function()
        local snacks = require 'snacks'
        snacks.picker.files {
          finder = 'files',
          format = 'file',
          show_empty = true,
          hidden = true,
          ignored = true,
          follow = false,
          supports_live = true,
        }
      end,
      'Find files',
    },

    ['<leader>fg'] = {
      function()
        local snacks = require 'snacks'
        snacks.picker.grep()
      end,
      'Grep files',
    },

    ['<leader>fo'] = {
      function()
        local snacks = require 'snacks'
        snacks.picker.recent()
      end,
      'Recent files',
    },

    ['<leader>tr'] = {
      function()
        local snacks = require 'snacks'
        snacks.picker.lsp_references()
      end,
      'LSP references',
    },

    ['<leader>td'] = {
      function()
        local snacks = require 'snacks'
        snacks.picker.lsp_definitions()
      end,
      'LSP definitions',
    },

    ['<leader>ti'] = {
      function()
        local snacks = require 'snacks'
        snacks.picker.lsp_implementations()
      end,
      'LSP implementations',
    },

    -- Explorer
    ['<leader>n'] = {
      function()
        local snacks = require 'snacks'
        snacks.explorer {
          show_empty = true,
          hidden = true,
          ignored = true,
          follow = false,
          supports_live = true,
        }
      end,
      'File Explorer',
    },

    -- Terminal
    ['<leader><leader>'] = {
      function()
        local snacks = require 'snacks'
        snacks.terminal()
      end,
      'Toggle Terminal',
    },
  },

  t = {
    ['<leader><leader>'] = {
      function()
        local snacks = require 'snacks'
        snacks.terminal()
      end,
      'Toggle Terminal',
    },
  },
}

exports.telescope = {
  plugin = true,

  n = {
    ['<leader>th'] = {
      function()
        local snacks_config = require 'plugins.configs.snacks'
        snacks_config.theme_picker()
      end,
      'Nvchad themes',
    },
  },
}

exports.whichkey = {
  plugin = true,

  n = {
    ['<leader>wK'] = {
      function()
        vim.cmd 'WhichKey'
      end,
      'Which-key all keymaps',
    },
    ['<leader>wk'] = {
      function()
        local input = vim.fn.input 'WhichKey: '
        vim.cmd('WhichKey ' .. input)
      end,
      'Which-key query lookup',
    },
  },
}

exports.blankline = {
  plugin = true,

  n = {
    ['<leader>cc'] = {
      function()
        local ok, start = require('indent_blankline.utils').get_current_context(
          vim.g.indent_blankline_context_patterns,
          vim.g.indent_blankline_use_treesitter_scope
        )

        if ok then
          vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start, 0 })
          vim.cmd [[normal! _]]
        end
      end,

      'Jump to current context',
    },
  },
}

exports.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    [']c'] = {
      function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          require('gitsigns').next_hunk()
        end)
        return '<Ignore>'
      end,
      'Jump to next hunk',
      opts = { expr = true },
    },

    ['[c'] = {
      function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          require('gitsigns').prev_hunk()
        end)
        return '<Ignore>'
      end,
      'Jump to prev hunk',
      opts = { expr = true },
    },

    -- Actions
    ['<leader>rh'] = {
      function()
        require('gitsigns').reset_hunk()
      end,
      'Reset hunk',
    },

    ['<leader>ph'] = {
      function()
        require('gitsigns').preview_hunk()
      end,
      'Preview hunk',
    },

    ['<leader>gb'] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      'Blame line',
    },
  },
}

exports.goto_preview = {
  plugin = true,

  -- Actions
  n = {
    -- Preview Definition
    ['<leader>pd'] = {
      function()
        local goto_preview = require 'goto-preview'
        goto_preview.goto_preview_definition()
      end,
      'Preview Definition',
    },
    ['<leader>pt'] = {
      function()
        local goto_preview = require 'goto-preview'
        goto_preview.goto_preview_type_definition()
      end,
      'Preview Type',
    },
    ['<leader>pi'] = {
      function()
        local goto_preview = require 'goto-preview'
        goto_preview.goto_preview_implementation()
      end,
      'Preview Implementation',
    },
    ['<leader>pr'] = {
      function()
        local goto_preview = require 'goto-preview'
        goto_preview.goto_preview_references()
      end,
      'Preview References',
    },
  },
}

exports.floating_windows = {
  n = {
    ['<S-left>'] = { '<C-w><', 'Decrease width' },
    ['<S-right>'] = { '<C-w>>', 'Increase width' },
    ['<S-up>'] = { '<C-w>-', 'Decrease height' },
    ['<S-down>'] = { '<C-w>+', 'Increase height' },
  },
}

exports.tabs = {
  plugin = false,

  n = {
    ['<leader>tt'] = {
      function()
        vim.cmd [[tabnew]]
      end,
      'Create new Tab',
    },
    ['<M-Up>'] = {
      function()
        vim.cmd [[tabnext]]
      end,
      '<cmd>tabnext<CR>',
      'Next Tab',
    },
    ['<M-Down>'] = {
      function()
        vim.cmd [[tabprevious]]
      end,
      'Previous Tab',
    },
  },
}

exports.buffers = {
  plugin = false,

  n = {
    ['tt'] = { '<cmd>enew<CR>', 'Create new buffer' },
    ['<M-q>'] = { '<cmd>bd<CR>', 'Close buffer' },
    ['<M-Right>'] = { '<cmd>bn<CR>', 'Next buffer' },    -- TODO: This mapping is not working
    ['<M-Left>'] = { '<cmd>bp<CR>', 'Previous buffer' }, -- TODO: This mapping is not working
    ['tl'] = { '<cmd>ls<CR>', 'List buffers' },
  },
}



exports.undotree = {
  plugin = true,

  n = {
    ['<leader>u'] = { '<cmd>UndotreeToggle<CR>', 'Toggle Undo Tree' },
  },
}

exports.trouble = {
  plugin = true,

  n = {
    ['<leader>T'] = {
      '<cmd>Trouble diagnostics toggle<CR>',
      'Trouble Diagnostic',
    },
  },
}

exports.treesitter_context = {
  plugin = true,

  n = {
    ['<leader>ss'] = { '<cmd>TreesitterContextToggle<CR>', 'Toggle Treesitter Context' },
  },
}

exports.rapidreturn = {
  plugin = true,

  n = {
    ['<leader>rs'] = { '<cmd>lua require("rapid_return").cmd.save()<CR>', 'Save Cursor' },
    ['<leader>rr'] = { '<cmd>lua require("rapid_return").cmd.rewind()<CR>', 'Rewind Cursor' },
    ['<leader>rR'] = {
      '<cmd>lua require("rapid_return").cmd.rewind_all()<CR>',
      'Rewind All Cursors',
    },
    ['<leader>rf'] = { '<cmd>lua require("rapid_return").cmd.forward()<CR>', 'Forward Cursor' },
    ['<leader>rc'] = { '<cmd>lua require("rapid_return").cmd.clear()<CR>', 'Clear History' },
    ['<leader>ruh'] = { '<cmd>lua require("rapid_return").ui.history()<CR>', 'Show History' },
  },
}

exports.lspsaga = {
  plugin = true,

  n = {
    ['<leader>ca'] = {
      function()
        vim.cmd [[Lspsaga code_action]]
      end,
      'Code Action',
    },
    ['<leader>rn'] = {
      function()
        vim.cmd [[Lspsaga rename]]
      end,
      'Rename Symbol',
    },
    ['<leader>so'] = {
      function()
        vim.cmd [[Lspsaga outline]]
      end,
      'Symbol Outline',
    },
    ['<leader>li'] = {
      function()
        vim.cmd [[Lspsaga incoming_calls]]
      end,
      'Incoming Calls',
    },
    ['<leader>lo'] = {
      function()
        vim.cmd [[Lspsaga outgoing_calls]]
      end,
      'Outgoing Calls',
    },
  },
}

exports.dap = {
  n = {
    ['..'] = { '<cmd>lua require("dap").step_over()<CR>', 'Step Over (shortcut)' },
    ['<leader>bb'] = { '<cmd>lua require("dap").toggle_breakpoint()<CR>', 'Toggle Breakpoint' },
    ['<leader>bB'] = {
      function()
        local dap = require 'dap'
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      'Toggle Conditional Breakpoint',
    },
    ['<leader>bc'] = { '<cmd>lua require("dap").continue()<CR>', 'Continue' },
    ['<leader>bso'] = { '<cmd>lua require("dap").step_over()<CR>', 'Step Over' },
    ['<leader>bsO'] = { '<cmd>lua require("dap").step_out()<CR>', 'Step Out' },
    ['<leader>bsi'] = { '<cmd>lua require("dap").step_into()<CR>', 'Step Into' },
    ['<leader>bk'] = { '<cmd>lua require("dap").close()<CR>', 'Stop' },
  },
}

exports.dapui = {
  n = {
    ['<leader>bu'] = { '<cmd>lua require("dapui").toggle()<CR>', 'Toggle DAP UI' },
    ['<leader>?'] = { '<cmd>lua require("dapui").eval()<CR>', 'Evaluate value' },
  },
}

exports.flash = {
  plugin = true,

  n = {
    ['s'] = {
      function()
        local flash = require 'flash'
        flash.jump()
      end,
      'Flash Jump',
    },
    ['S'] = {
      function()
        local flash = require 'flash'
        flash.treesitter()
      end,
      'Flash Treesitter',
    },
    ['R'] = {
      function()
        local flash = require 'flash'
        flash.remote()
      end,
      'Flash Remote',
    },
  },

  v = {
    ['s'] = {
      function()
        local flash = require 'flash'
        flash.jump()
      end,
      'Flash Jump',
    },
    ['S'] = {
      function()
        local flash = require 'flash'
        flash.treesitter()
      end,
      'Flash Treesitter',
    },
  },
}

exports.neotest = {
  plugin = true,

  n = {
    ['<leader>mr'] = {
      function()
        local neotest = require 'neotest'
        neotest.run.run { suite = false }
      end,
      'Run Nearest Test',
    },
    ['<leader>md'] = {
      function()
        local neotest = require 'neotest'
        neotest.run.run { suite = false, strategy = 'dap' }
      end,
      'Debug nearest test',
    },
    ['<leader>mw'] = {
      function()
        local neotest = require 'neotest'
      end,
      'Toggle test watcher',
    },
    ['<leader>ms'] = {
      function()
        local neotest = require 'neotest'
        neotest.summary.toggle()
      end,
      'Test summary',
    },
    ['<leader>mo'] = {
      function()
        local neotest = require 'neotest'
        neotest.output.open()
      end,
      'Test output',
    },
  },
}

return exports
