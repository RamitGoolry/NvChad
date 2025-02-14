local config = {
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
