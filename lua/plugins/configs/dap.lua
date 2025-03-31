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
        size = 40,
        position = 'left',
      },
      {
        elements = {
          'repl',
          'console',
          'scopes',
        },
        size = 0.35, -- 25% of total lines
        position = 'bottom',
      },
    },
  }

  dap_go.setup {
    -- Additional dap configurations can be added.
    -- dap_configurations accepts a list of tables where each entry
    -- represents a dap configuration. For more details do:
    -- :help dap-configuration
    dap_configurations = {
      {
        -- Must be "go" or it will be ignored by the plugin
        type = 'go',
        name = 'Attach remote',
        mode = 'remote',
        request = 'attach',
      },
    },
    -- delve configurations
    delve = {
      -- the path to the executable dlv which will be used for debugging.
      -- by default, this is the "dlv" executable on your PATH.
      path = 'dlv',
      -- time to wait for delve to initialize the debug session.
      -- default to 20 seconds
      initialize_timeout_sec = 60,
      -- a string that defines the port to start delve debugger.
      -- default to string "${port}" which instructs nvim-dap
      -- to start the process in a random available port.
      -- if you set a port in your debug configuration, its value will be
      -- assigned dynamically.
      port = '${port}',
      -- additional args to pass to dlv
      args = {},
      -- the build flags that are passed to delve.
      -- defaults to empty string, but can be used to provide flags
      -- such as "-tags=unit" to make sure the test suite is
      -- compiled during debugging, for example.
      -- passing build flags using args is ineffective, as those are
      -- ignored by delve in dap mode.
      -- avaliable ui interactive function to prompt for arguments get_arguments
      build_flags = {},
      -- whether the dlv process to be created detached or not. there is
      -- an issue on delve versions < 1.24.0 for Windows where this needs to be
      -- set to false, otherwise the dlv server creation will fail.
      -- avaliable ui interactive function to prompt for build flags: get_build_flags
      detached = vim.fn.has 'win32' == 0,
      -- the current working directory to run dlv from, if other than
      -- the current working directory.
      cwd = nil,
    },
    -- options related to running closest test
    tests = {
      -- enables verbosity when running the test.
      verbose = false,
    },
  }

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

  vim.fn.sign_define(
    'DapBreakpoint',
    { text = '', texthl = 'DiagnosticSignError', linehl = '', numhl = '' }
  )

  vim.fn.sign_define(
    'DapBreakpointCondition',
    { text = '', texthl = 'DiagnosticSignError', linehl = '', numhl = '' }
  )

  vim.fn.sign_define(
    'DapStopped',
    { text = '', texthl = 'DiagnosticSignWarn', linehl = '', numhl = '' }
  )
end

return exports
