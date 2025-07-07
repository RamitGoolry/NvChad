local M = {}

function M.load_snippets(luasnip)
  -- Clear existing snippets
  local snippet_collection = require 'luasnip.session.snippet_collection'
  
  -- Load language-specific snippets
  local languages = { 'lua', 'go' }
  
  for _, lang in ipairs(languages) do
    local ok, snippets = pcall(require, 'snippets.' .. lang)
    if ok then
      snippet_collection.clear_snippets(lang)
      luasnip.add_snippets(lang, snippets)
    end
  end
end

return M