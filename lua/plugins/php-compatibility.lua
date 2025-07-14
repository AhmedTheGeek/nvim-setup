-- Enhanced PHP compatibility checking with Intelephense
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "folke/trouble.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    
    -- Function to get PHP version from composer.json
    local function get_php_version_from_composer()
      local composer_path = vim.fn.getcwd() .. "/composer.json"
      if vim.fn.filereadable(composer_path) == 0 then
        return nil
      end
      
      local composer_content = vim.fn.readfile(composer_path)
      local ok, composer_json = pcall(vim.fn.json_decode, table.concat(composer_content, "\n"))
      
      if not ok then
        return nil
      end
      
      if composer_json and composer_json.require and composer_json.require.php then
        local php_constraint = composer_json.require.php
        -- Extract version number from constraints like "^7.4", ">=7.4", "~7.4.0", etc.
        local version = php_constraint:match("(%d+%.%d+)")
        return version
      end
      
      return nil
    end
    
    -- Function to get stubs based on PHP version
    local function get_stubs_for_php_version(version)
      if not version then
        return {}
      end
      
      local major, minor = version:match("(%d+)%.(%d+)")
      major = tonumber(major)
      minor = tonumber(minor)
      
      -- Base stubs available in all PHP versions
      local stubs = {
        "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "ctype", "curl",
        "date", "dba", "dom", "enchant", "exif", "fileinfo", "filter", "ftp", "gd", 
        "gettext", "gmp", "hash", "iconv", "imap", "intl", "json", "ldap", "libxml", 
        "mbstring", "meta", "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre", 
        "PDO", "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar", 
        "posix", "pspell", "readline", "Reflection", "session", "shmop", "SimpleXML", 
        "snmp", "soap", "sockets", "SPL", "sqlite3", "standard", "superglobals", 
        "sysvmsg", "sysvsem", "sysvshm", "tidy", "tokenizer", "xml", "xmlreader", 
        "xmlrpc", "xmlwriter", "xsl", "zip", "zlib"
      }
      
      -- Add version-specific stubs
      if major >= 7 then
        table.insert(stubs, "Zend OPcache")
      end
      
      if major >= 7 and minor >= 2 then
        table.insert(stubs, "sodium")
      end
      
      -- Remove stubs for features not available in older versions
      if major < 8 then
        -- Remove PHP 8 specific stubs
        local php8_stubs = {"FFI"}
        for _, stub in ipairs(php8_stubs) do
          for i, s in ipairs(stubs) do
            if s == stub then
              table.remove(stubs, i)
              break
            end
          end
        end
      end
      
      return stubs
    end
    
    -- Enhanced Intelephense setup
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    
    lspconfig.intelephense.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- Show PHP version on file open
        local php_version = get_php_version_from_composer()
        if php_version then
          vim.notify("PHP " .. php_version .. " compatibility mode active", vim.log.levels.INFO)
        end
        
        -- Configure diagnostics display
        vim.diagnostic.config({
          virtual_text = {
            prefix = '●',
            source = "if_many",
          },
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })
      end,
      settings = {
        intelephense = {
          stubs = get_stubs_for_php_version(get_php_version_from_composer()),
          files = {
            maxSize = 5000000,
          },
          environment = {
            phpVersion = get_php_version_from_composer() or "7.4",
            shortOpenTag = false,
            includePaths = {},
          },
          runtime = "", -- Empty string to use phpVersion from environment
          maxMemory = 512,
          licenceKey = "", -- Add your license key here if you have one
          telemetry = {
            enabled = false,
          },
          format = {
            enable = false,
          },
          completion = {
            insertUseDeclaration = true,
            fullyQualifyGlobalConstantsAndFunctions = false,
            triggerParameterHints = true,
            maxItems = 100,
          },
          diagnostics = {
            enable = true,
            deprecated = true,
            run = "onType", -- Run diagnostics on type for immediate feedback
            -- All diagnostic types enabled
            embeddedLanguages = true,
            languageConstraints = true,
            undefinedSymbols = true,
            undefinedVariables = true,
            undefinedTypes = true,
            undefinedFunctions = true,
            undefinedConstants = true,
            undefinedClassConstants = true,
            undefinedMethods = true,
            undefinedProperties = true,
            unusedSymbols = true,
            unexpectedTokens = true,
            duplicateSymbols = true,
            argumentCount = true,
            typeErrors = true,
            missingReturn = true,
            deadCode = true,
            unknownProperties = true,
            propertyInitialization = true,
            unreachableCode = true,
          },
        },
      },
      on_new_config = function(new_config, new_root_dir)
        -- Update PHP version when changing projects
        local php_version = get_php_version_from_composer()
        if php_version then
          new_config.settings.intelephense.environment.phpVersion = php_version
          new_config.settings.intelephense.stubs = get_stubs_for_php_version(php_version)
          vim.notify("Updated to PHP " .. php_version .. " for " .. vim.fn.fnamemodify(new_root_dir, ":t"), vim.log.levels.INFO)
        end
      end,
    })
    
    -- Set up dynamic PHP version diagnostics
    local php_version = get_php_version_from_composer()
    if php_version then
      -- Use both static and dynamic checkers for comprehensive coverage
      -- local static_diagnostics = require("utils.php-version-diagnostics")
      -- static_diagnostics.setup(php_version)
      
      local dynamic_diagnostics = require("utils.php-dynamic-check")
      dynamic_diagnostics.setup(php_version)
    end
  end,
}
