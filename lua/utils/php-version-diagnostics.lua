-- Custom PHP version compatibility diagnostics
local M = {}

-- PHP features and their minimum version requirements
local php_features = {
  -- PHP 8.0 features
  ["str_contains"] = { version = "8.0", type = "function" },
  ["str_starts_with"] = { version = "8.0", type = "function" },
  ["str_ends_with"] = { version = "8.0", type = "function" },
  ["fdiv"] = { version = "8.0", type = "function" },
  ["get_debug_type"] = { version = "8.0", type = "function" },
  ["get_resource_id"] = { version = "8.0", type = "function" },
  ["match"] = { version = "8.0", type = "keyword" },
  ["?->"] = { version = "8.0", type = "operator", pattern = "%?%->" },
  
  -- PHP 7.4 features
  ["=>"] = { version = "7.4", type = "arrow_function", pattern = "fn%s*%(" },
  
  -- PHP 7.3 features
  ["is_countable"] = { version = "7.3", type = "function" },
  ["array_key_first"] = { version = "7.3", type = "function" },
  ["array_key_last"] = { version = "7.3", type = "function" },
  
  -- PHP 7.2 features
  ["sodium_"] = { version = "7.2", type = "function_prefix" },
  
  -- PHP 7.1 features
  ["is_iterable"] = { version = "7.1", type = "function" },
  
  -- PHP 7.0 features  
  ["random_bytes"] = { version = "7.0", type = "function" },
  ["random_int"] = { version = "7.0", type = "function" },
  ["intdiv"] = { version = "7.0", type = "function" },
  
  -- PHP 8.1 features
  ["array_is_list"] = { version = "8.1", type = "function" },
  ["enum_exists"] = { version = "8.1", type = "function" },
  ["readonly"] = { version = "8.1", type = "keyword", pattern = "readonly%s+%$" },
  
  -- PHP 8.2 features
  ["ini_parse_quantity"] = { version = "8.2", type = "function" },
  ["curl_upkeep"] = { version = "8.2", type = "function" },
  ["openssl_cipher_key_length"] = { version = "8.2", type = "function" },
  ["sodium_crypto_stream_xchacha20"] = { version = "8.2", type = "function" },
  ["#%["] = { version = "8.0", type = "attribute", pattern = "#%[" },
}

-- Compare PHP versions
local function version_compare(v1, v2)
  local v1_parts = vim.split(v1, "%.")
  local v2_parts = vim.split(v2, "%.")
  
  for i = 1, math.max(#v1_parts, #v2_parts) do
    local p1 = tonumber(v1_parts[i]) or 0
    local p2 = tonumber(v2_parts[i]) or 0
    if p1 < p2 then return -1 end
    if p1 > p2 then return 1 end
  end
  
  return 0
end

-- Check PHP code for version compatibility
function M.check_php_compatibility(bufnr, php_version)
  if not php_version then
    return {}
  end
  
  local diagnostics = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  for line_num, line in ipairs(lines) do
    -- Skip comments and strings
    if line:match("^%s*//") or line:match("^%s*#") or line:match("^%s*%*") then
      goto continue
    end
    
    -- Check each PHP feature
    for feature, info in pairs(php_features) do
      local found = false
      local col_start, col_end
      
      if info.pattern then
        -- Use custom pattern
        col_start, col_end = line:find(info.pattern)
        found = col_start ~= nil
      elseif info.type == "function" then
        -- Look for function calls
        col_start, col_end = line:find(feature .. "%s*%(")
        found = col_start ~= nil
      elseif info.type == "function_prefix" then
        -- Look for functions starting with prefix
        col_start, col_end = line:find(feature .. "%w+%s*%(")
        found = col_start ~= nil
      elseif info.type == "keyword" then
        -- Look for keywords
        col_start, col_end = line:find("%f[%w]" .. feature .. "%f[%W]")
        found = col_start ~= nil
      end
      
      if found and version_compare(php_version, info.version) < 0 then
        table.insert(diagnostics, {
          lnum = line_num - 1,
          col = col_start - 1,
          end_col = col_end,
          severity = vim.diagnostic.severity.ERROR,
          message = string.format(
            "'%s' requires PHP %s or later (current: PHP %s)",
            feature:gsub("%%", ""),
            info.version,
            php_version
          ),
          source = "php-version",
        })
      end
    end
    
    ::continue::
  end
  
  return diagnostics
end

-- Set up autocmd to check PHP files
function M.setup(php_version)
  local ns = vim.api.nvim_create_namespace("php_version_diagnostics")
  
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
    pattern = "*.php",
    callback = function(args)
      local diagnostics = M.check_php_compatibility(args.buf, php_version)
      vim.diagnostic.set(ns, args.buf, diagnostics)
      
      if #diagnostics > 0 then
        vim.notify(
          string.format("%d PHP %s compatibility issue%s found", 
            #diagnostics, 
            php_version,
            #diagnostics > 1 and "s" or ""),
          vim.log.levels.WARN
        )
      end
    end,
  })
end

return M