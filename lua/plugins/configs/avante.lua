local options = {
  debug = false,
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | [string]
  provider = 'claude', -- Only recommend using Claude
  auto_suggestions_provider = 'claude',
  ---@alias Tokenizer "tiktoken" | "hf"
  -- Used for counting tokens and encoding text.
  -- By default, we will use tiktoken.
  -- For most providers that we support we will determine this automatically.
  -- If you wish to use a given implementation, then you can override it here.
  tokenizer = 'tiktoken',
  ---@type AvanteSupportedProvider
  openai = {
    endpoint = 'https://api.openai.com/v1',
    model = 'gpt-4o',
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 4096,
  },
  ---@type AvanteSupportedProvider
  copilot = {
    endpoint = 'https://api.githubcopilot.com',
    model = 'gpt-4o-2024-05-13',
    proxy = nil, -- [protocol://]host[:port] Use this proxy
    allow_insecure = false, -- Allow insecure server connections
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 4096,
  },
  ---@type AvanteAzureProvider
  azure = {
    endpoint = '', -- example: "https://<your-resource-name>.openai.azure.com"
    deployment = '', -- Azure deployment name (e.g., "gpt-4o", "my-gpt-4o-deployment")
    api_version = '2024-06-01',
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 4096,
  },
  ---@type AvanteSupportedProvider
  claude = {
    endpoint = 'https://api.anthropic.com',
    model = 'claude-3-5-sonnet-20241022',
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 8000,
  },
  ---@type AvanteSupportedProvider
  gemini = {
    endpoint = 'https://generativelanguage.googleapis.com/v1beta/models',
    model = 'gemini-1.5-flash-latest',
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 4096,
  },
  ---@type AvanteSupportedProvider
  cohere = {
    endpoint = 'https://api.cohere.com/v2',
    model = 'command-r-plus-08-2024',
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 4096,
  },
  ---To add support for custom provider, follow the format below
  ---See https://github.com/yetone/avante.nvim/wiki#custom-providers for more details
  ---@type {[string]: AvanteProvider}
  vendors = {
    ---@type AvanteSupportedProvider
    ['claude-haiku'] = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-3-5-haiku-20241022',
      timeout = 30000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 8000,
    },
    ---@type AvanteSupportedProvider
    ['claude-opus'] = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-3-opus-20240229',
      timeout = 30000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 8000,
    },
  },
  ---Specify the behaviour of avante.nvim
  ---1. auto_apply_diff_after_generation: Whether to automatically apply diff after LLM response.
  ---                                     This would simulate similar behaviour to cursor. Default to false.
  ---2. auto_set_keymaps                : Whether to automatically set the keymap for the current line. Default to true.
  ---                                     Note that avante will safely set these keymap. See https://github.com/yetone/avante.nvim/wiki#keymaps-and-api-i-guess for more details.
  ---3. auto_set_highlight_group        : Whether to automatically set the highlight group for the current line. Default to true.
  ---4. support_paste_from_clipboard    : Whether to support pasting image from clipboard. This will be determined automatically based whether img-clip is available or not.
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
  },
  history = {
    max_tokens = 4096,
    storage_path = vim.fn.stdpath 'state' .. '/avante',
    paste = {
      extension = 'png',
      filename = 'pasted-%Y-%m-%d-%H-%M-%S',
    },
  },
  highlights = {
    ---@type AvanteConflictHighlights
    diff = {
      current = 'DiffText',
      incoming = 'DiffAdd',
    },
  },
  mappings = {
    ---@class AvanteConflictMappings
    diff = {
      ours = 'co',
      theirs = 'ct',
      all_theirs = 'ca',
      both = 'cb',
      cursor = 'cc',
      next = ']x',
      prev = '[x',
    },
    suggestion = {
      accept = '<M-l>',
      next = '<M-]>',
      prev = '<M-[>',
      dismiss = '<C-]>',
    },
    jump = {
      next = ']]',
      prev = '[[',
    },
    submit = {
      normal = '<CR>',
      insert = '<C-s>',
    },
    -- NOTE: The following will be safely set by avante.nvim
    ask = '<leader>aa',
    edit = '<leader>ae',
    refresh = '<leader>ar',
    focus = '<leader>af',
    toggle = {
      default = '<leader><leader>',
      debug = '<leader>ad',
      hint = '<leader>ah',
      suggestion = '<leader>as',
      repomap = '<leader>aR',
    },
    sidebar = {
      apply_all = 'A',
      apply_cursor = 'a',
      switch_windows = '<Tab>',
      reverse_switch_windows = '<S-Tab>',
    },
  },
  windows = {
    ---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
    position = 'left',
    wrap = true, -- similar to vim.o.wrap
    width = 30, -- default % based on available width in vertical layout
    height = 30, -- default % based on available height in horizontal layout
    sidebar_header = {
      enabled = true, -- true, false to enable/disable the header
      align = 'center', -- left, center, right for title
      rounded = true,
    },
    input = {
      prefix = '> ',
      height = 8, -- Height of the input window in vertical layout
    },
    edit = {
      border = 'rounded',
      start_insert = true, -- Start insert mode when opening the edit window
    },
    ask = {
      floating = false, -- Open the 'AvanteAsk' prompt in a floating window
      border = 'rounded',
      start_insert = false, -- Start insert mode when opening the ask window
      ---@alias AvanteInitialDiff "ours" | "theirs"
      focus_on_apply = 'theirs', -- which diff to focus after applying
    },
  },
  --- @class AvanteConflictConfig
  diff = {
    autojump = true,
    --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
    --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
    --- Disable by setting to -1.
    override_timeoutlen = 500,
  },
  --- @class AvanteHintsConfig
  hints = {
    enabled = true,
  },
}

return options
