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
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
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

  n = {
    -- toggle
    ['<leader>n'] = {
      function()
        vim.cmd [[NvimTreeToggle]]
      end,
      'Toggle nvimtree',
    },

    -- focus
    ['<leader>e'] = {
      function()
        vim.cmd [[NvimTreeFocus]]
      end,
      'Focus nvimtree',
    },
  },
}

exports.telescope = {
  plugin = true,

  n = {
    ['<leader>ff'] = {
      function()
        vim.cmd [[Telescope find_files]]
      end,
      'Find files',
    },

    ['<leader>fg'] = {
      function()
        local telescope = require 'telescope'
        telescope.extensions.live_grep_args.live_grep_args()
      end,
      'Live Grep',
    },

    ['<leader>fa'] = {
      function()
        vim.cmd [[Telescope find_files follow=true no_ignore=true hidden=true]]
      end,
      'Find all',
    },

    ['<leader>fb'] = {
      function()
        vim.cmd [[Telescope buffers]]
      end,
      'Find buffers',
    },

    ['<leader>fh'] = {
      function()
        vim.cmd [[Telescope help_tags]]
      end,
      'Help page',
    },
    ['<leader>fo'] = {
      function()
        vim.cmd [[Telescope oldfiles]]
      end,
      'Find oldfiles',
    },
    ['<leader>fz'] = {
      function()
        vim.cmd [[Telescope current_buffer_fuzzy_find]]
      end,
      'Find in current buffer',
    },

    ['<leader>cm'] = {
      function()
        vim.cmd [[Telescope git_commits]]
      end,
      'Git commits',
    },
    ['<leader>gt'] = {
      function()
        vim.cmd [[Telescope git_status]]
      end,
      'Git status',
    },

    ['<leader>pt'] = {
      function()
        vim.cmd [[Telescope terms]]
      end,
      'Pick hidden term',
    },

    ['<leader>th'] = {
      function()
        vim.cmd [[Telescope themes]]
      end,
      'Nvchad themes',
    },

    ['<leader>ma'] = {
      function()
        vim.cmd [[Telescope marks]]
      end,
      'Bookmarks',
    },

    ['<leader>tr'] = {
      function()
        vim.cmd [[Telescope lsp_references]]
      end,
      'LSP references',
    },
  },
}

exports.nvterm = {
  plugin = true,

  t = {
    -- toggle in terminal mode
    ['<Space><Space>'] = {
      function()
        require('nvterm.terminal').toggle 'float'
      end,
      'Toggle floating term',
    },

    ['<A-h>'] = {
      function()
        require('nvterm.terminal').toggle 'horizontal'
      end,
      'Toggle horizontal term',
    },

    ['<A-v>'] = {
      function()
        require('nvterm.terminal').toggle 'vertical'
      end,
      'Toggle vertical term',
    },
  },

  n = {
    -- toggle in normal mode
    ['<Space><Space>'] = {
      function()
        require('nvterm.terminal').toggle 'float'
      end,
      'Toggle floating term',
    },

    ['<A-h>'] = {
      function()
        require('nvterm.terminal').toggle 'horizontal'
      end,
      'Toggle horizontal term',
    },

    ['<A-v>'] = {
      function()
        require('nvterm.terminal').toggle 'vertical'
      end,
      'Toggle vertical term',
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

    ['<leader>td'] = {
      function()
        require('gitsigns').toggle_deleted()
      end,
      'Toggle deleted',
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
    ['<leader>tn'] = {
      function()
        vim.cmd [[tabnext]]
      end,
      '<cmd>tabnext<CR>',
      'Next Tab',
    },
    ['<leader>tp'] = {
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
    ['tq'] = { '<cmd>bd<CR>', 'Close buffer' },
    ['tn'] = { '<cmd>bn<CR>', 'Next buffer' },
    ['tp'] = { '<cmd>bp<CR>', 'Previous buffer' },
    ['td'] = { '<cmd>bd<CR>', 'Delete buffer' },
    ['tl'] = { '<cmd>ls<CR>', 'List buffers' },
  },
}

exports.harpoon = {
  plugin = true,

  n = {
    ['<leader>;'] = {
      function()
        local harpoon = require 'harpoon'
        harpoon:list():add()
      end,
      'Add File to Harpoon',
    },
    ['<leader>h'] = {
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      'Harpoon Quick Menu',
    },
    ['<C-n>'] = {
      function()
        local harpoon = require 'harpoon'
        harpoon:list():next()
      end,
      'Harpoon to next file',
    },
    ['<C-p>'] = {
      function()
        local harpoon = require 'harpoon'
        harpoon:list():prev()
      end,
      'Harpoon to previous file',
    },
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
    ['rs'] = { '<cmd>lua require("rapid_return").cmd.save()<CR>', 'Save Cursor' },
    ['rr'] = { '<cmd>lua require("rapid_return").cmd.rewind()<CR>', 'Rewind Cursor' },
    ['rR'] = { '<cmd>lua require("rapid_return").cmd.rewind_all()<CR>', 'Rewind All Cursors' },
    ['rf'] = { '<cmd>lua require("rapid_return").cmd.forward()<CR>', 'Forward Cursor' },
    ['rc'] = { '<cmd>lua require("rapid_return").cmd.clear()<CR>', 'Clear History' },
    ['ruh'] = { '<cmd>lua require("rapid_return").ui.history()<CR>', 'Show History' },
  },
}

exports.lspsaga = {
  plugin = true,

  n = {
    ['<leader>ca'] = { '<cmd>Lspsaga code_action<CR>', 'Code Action' },
    ['<leader>rn'] = { '<cmd>Lspsaga rename<CR>', 'Rename Symbol' },
    ['<leader>so'] = { '<cmd>Lspsaga outline<CR>', 'Symbol Outline' },
  },
}

exports.dap = {
  n = {
    ['..'] = { '<cmd>lua require("dap").step_over()<CR>', 'Step Over (shortcut)' },
    ['<leader>bb'] = { '<cmd>lua require("dap").toggle_breakpoint()<CR>', 'Toggle Breakpoint' },
    ['<leader>bc'] = { '<cmd>lua require("dap").continue()<CR>', 'Continue' },
    ['<leader>bso'] = { '<cmd>lua require("dap").step_over()<CR>', 'Step Over' },
    ['<leader>bsO'] = { '<cmd>lua require("dap").step_out()<CR>', 'Step Out' },
    ['<leader>bsi'] = { '<cmd>lua require("dap").step_into()<CR>', 'Step Into' },
    ['<leader>br'] = { '<cmd>lua require("dap").repl.toggle()<CR>', 'Toggle DAP Replay' },
    ['<leader>bgc'] = { '<cmd>lua require("dap").run_to_cursor()<CR>', 'Run to Cursor' },
    ['<leader>blb'] = { '<cmd>Telescope dap list_breakpoints()<CR>', 'List Breakpoints' },
  },
}

exports.dapui = {
  n = {
    ['<leader>bu'] = { '<cmd>lua require("dapui").toggle()<CR>', 'Toggle DAP UI' },
    ['<leader>?'] = { '<cmd>lua require("dapui").eval()<CR>', 'Evaluate value' },
  },
}

-- exports.dap_python = {
-- TODO: Figure out file type specific mappings
--   n = {
--     ['<leader>bt'] = { '<cmd>lua require("dap-python").test_method()<cr>', 'Test Method (Python)' },
--   },
-- }
-- This can be done through a custom function in the keymap or ftplugins

exports.dap_go = {
  n = {
    ['<leader>bt'] = { '<cmd>lua require("dap-go").debug_test()<cr>', 'Debug Test (Go)' },
    ['<leader>blt'] = { '<cmd>lua require("dap-go").debug_last_test()<cr>', 'Debug Last Test (Go)' },
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

exports.octo = {
  plugin = true,

  n = {
    ['O'] = { '<cmd>Octo actions<cr>', 'Octo Actions' },
  },
}

exports.neotest = {
  plugin = true,

  n = {
    ['<leader>Ntr'] = {
      function()
        local neotest = require 'neotest'
        neotest.run.run { suite = false }
      end,
      'Run Nearest Test',
    },
    ['<leader>Ntd'] = {
      function()
        local neotest = require 'neotest'
        neotest.run.run { suite = false, strategy = 'dap' }
      end,
      'Debug nearest test',
    },
    ['<leader>Ntw'] = {
      function()
        -- TODO
      end,
      'Toggle test watcher',
    },
  },
}

exports.kubectl = {
  plugin = true,

  n = {
    ['<leader>k'] = {
      function()
        require('kubectl').open()
      end,
      'Kubectl',
    },
  },
}

return exports
