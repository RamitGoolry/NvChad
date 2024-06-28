local exports = {}

exports.config = function()
  local dap = require 'dap'
  local dapui = require 'dapui'
  local dap_go = require 'dap-go'
  local dap_python = require 'dap-python'

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

  -- DAP Python
  dap_python.setup '/Users/ramit/.pyenv/shims/python3'
  dap_python.test_runner = 'pytest'

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

  vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
end

return exports
