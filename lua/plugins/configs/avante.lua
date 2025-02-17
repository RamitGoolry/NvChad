local options = {
  debug = false,
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | [string]
  provider = 'openrouter-deepseek-r1',
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
    model = 'claude-3-5-sonnet-latest',
    timeout = 60000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 8192,
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

  vendors = {
    ---@type AvanteProvider
    ['deepseek'] = {
      __inherited_from = 'openai',
      endpoint = 'https://api.deepseek.com/v1',
      model = 'deepseek-reasoner',
      timeout = 120000,
      temperature = 0,
      max_tokens = 32768,
    },

    ---@type AvanteProvider
    ['ollama-deepseek-r1-14b'] = {
      -- __inherited_from = 'openai',
      endpoint = 'http://localhost:11434/api',
      model = 'deepseek-r1:14b',
      timeout = 120000,
      temperature = 0,
      max_tokens = 32768,
      parse_curl_args = function(opts, code_opts)
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
      end,
      parse_stream_data = function(data, handler_opts)
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
      end,
    },

    ---@type AvanteProvider
    ['openrouter-deepseek-r1'] = {
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
    ['o3-mini-high'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'openai/o3-mini-high',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 900000, -- 15 Min
      temperature = 0,
      max_tokens = 8192,
      disable_tools = true,
    },

    ---@type AvanteProvider
    ['qwen-max'] = {
      __inherited_from = 'openai',
      endpoint = 'https://openrouter.ai/api/v1',
      model = 'qwen/qwen-max',
      api_key_name = 'OPENROUTER_DEEPSEEK_API_KEY',
      timeout = 900000, -- 15 Min
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
}

return options
