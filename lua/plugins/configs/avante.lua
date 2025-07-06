local function ollama_parse_curl_args(opts, code_opts)
  return {
    url = opts.endpoint .. '/chat',
    headers = {
      ['Accept'] = 'application/json',
      ['Content-Type'] = 'application/json',
    },
    body = {
      model = opts.model,
      options = {
        num_ctx = 16384,
      },
      messages = require('avante.providers').copilot.parse_messages(code_opts), -- you can make your own message, but this is very advanced
      stream = true,
    },
  }
end

local function ollama_parse_stream_data(data, handler_opts)
  -- Parse the JSON data
  local json_data = vim.fn.json_decode(data)
  -- Check for stream completion marker first
  if json_data and json_data.done then
    handler_opts.on_complete(nil) -- Properly terminate the stream
    return
  end
  -- Process normal message content
  if json_data and json_data.message and json_data.message.content then
    -- Extract the content from the message
    local content = json_data.message.content
    -- Call the handler with the content
    handler_opts.on_chunk(content)
  end
end

local options = {
  debug = false,
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | [string]
  provider = 'gemini-2.5-pro',
  auto_suggestions_provider = 'claude',

  tokenizer = 'tiktoken',
  ---@type AvanteSupportedProvider
  openai = {
    endpoint = 'https://api.openai.com/v1',
    model = 'gpt-4o',
    timeout = 30000,
    temperature = 0,
    max_tokens = 4096,
  },
  ---@type AvanteSupportedProvider
  claude = {
    endpoint = 'https://api.anthropic.com',
    model = 'claude-3-7-sonnet-20250219',
    timeout = 600000, -- 10 Min
    temperature = 0,
    max_tokens = 16384,
  },
  vendors = {
    ---@type AvanteProvider
    ['ollama/deepseek-r1-14b'] = {
      -- __inherited_from = 'openai',
      endpoint = 'http://localhost:11434/api',
      model = 'deepseek-r1:14b',
      timeout = 120000,
      temperature = 0,
      max_tokens = 32768,
      parse_curl_args = ollama_parse_curl_args,
      parse_stream_data = ollama_parse_stream_data,
    },

    ---@type AvanteProvider
    ['openrouter/deepseek-r1'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'deepseek/deepseek-r1',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 900000, -- 15 Min
      temperature = 0,
      max_tokens = 8192,
      disable_tools = true,
    },

    ---@type AvanteProvider
    ['openrouter/o3-mini-high'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'openai/o3-mini-high',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 900000, -- 15 Min
      temperature = 0,
      max_tokens = 16384,
    },

    ---@type AvanteProvider
    ['openrouter/claude-3.7-sonnet'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'anthropic/claude-3.7-sonnet',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 900000, -- 15 Min
      temperature = 0,
      max_tokens = 32768,
    },

    ---@type AvanteProvider
    ['openrouter/claude-3.7-sonnet-thinking'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'anthropic/claude-3.7-sonnet:thinking',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 900000, -- 15 Min
      temperature = 0,
      max_tokens = 32768,
    },

    ---@type AvanteProvider
    ['gemini-2.0-flash-lite'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'google/gemini-2.0-flash-lite-001',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 20000, -- 20 Sec
      temperature = 0,
      max_tokens = 8192,
    },

    ---@type AvanteProvider
    ['gemini-2.0-flash'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'google/gemini-2.0-flash-001',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 20000, -- 20 Sec
      temperature = 0,
      max_tokens = 8192,
    },

    ---@type AvanteProvider
    ['gemini-2.5-pro'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'google/gemini-2.5-pro-preview-03-25',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 20000, -- 20 Sec
      temperature = 0,
      max_tokens = 8192,
    },
  },
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
  },
  history = {
    max_tokens = 262144,
    storage_path = vim.fn.stdpath 'state' .. '/avante',
    paste = {
      extension = 'png',
      filename = 'pasted-%Y-%m-%d-%H-%M-%S',
    },
  },
  highlights = {
    ---@type AvanteConflictHighlights
    diff = {
      current = 'DiffDelete',
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

    ask = '<leader>aa',
    edit = '<leader>ae',
    refresh = '<leader>ar',
    focus = '<leader>af',
    toggle = {
      default = '<leader>aa',
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
    position = 'right',
    wrap = true, -- similar to vim.o.wrap
    width = 30, -- default % based on available width in vertical layout
    height = 30, -- default % based on available height in horizontal layout
    sidebar_header = {
      enabled = true,
      align = 'center', -- left, center, right for title
      rounded = true,
    },
    input = {
      prefix = '> ',
      height = 10, -- Height of the input window in vertical layout
    },
    edit = {
      border = 'rounded',
      start_insert = true,
    },
    ask = {
      floating = false,
      border = 'rounded',
      start_insert = false,
      ---@alias AvanteInitialDiff "ours" | "theirs"
      focus_on_apply = 'theirs', -- which diff to focus after applying
    },
  },
  --- @class AvanteConflictConfig
  diff = {
    autojump = true,
    override_timeoutlen = 500,
  },
  --- @class AvanteHintsConfig
  hints = {
    enabled = true,
  },
  --- @class AvanteRepoMapConfig
  repo_map = {
    ignore_patterns = { '%.git', '%.worktree', '__pycache__', 'node_modules' }, -- ignore files matching these
    negate_patterns = {}, -- negate ignore files matching these.
  },
  --- @class AvanteFileSelectorConfig
  file_selector = {
    --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string | fun(params: avante.file_selector.IParams|nil): nil
    provider = 'snacks',
    -- Options override for custom providers
    provider_opts = {},
  },
  suggestion = {
    debounce = 600,
    throttle = 600,
  },
  -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
  system_prompt = function()
    local hub = require('mcphub').get_hub_instance()
    return hub:get_active_servers_prompt()
  end,
  -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
  custom_tools = function()
    return {
      require('mcphub.extensions.avante').mcp_tool(),
    }
  end,
}

return options
