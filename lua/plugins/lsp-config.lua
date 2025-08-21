return {
  -- Mason for managing LSP servers
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },
  
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- PHP Intelephense with WordPress support
      lspconfig.intelephense.setup({
        capabilities = capabilities,
        settings = {
          intelephense = {
            stubs = {
              "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "ctype", "curl", 
              "date", "dba", "dom", "enchant", "exif", "fileinfo", "filter", "fpm", "ftp", 
              "gd", "gettext", "gmp", "hash", "iconv", "imap", "intl", "json", "ldap", 
              "libxml", "mbstring", "mcrypt", "meta", "mysqli", "oci8", "odbc", "openssl", 
              "pcntl", "pcre", "PDO", "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", 
              "pgsql", "Phar", "posix", "pspell", "readline", "Reflection", "session", 
              "shmop", "SimpleXML", "snmp", "soap", "sockets", "sodium", "SPL", "sqlite3", 
              "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm", "tidy", 
              "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter", "xsl", "Zend OPcache", 
              "zip", "zlib", 
              "wordpress", "wordpress-globals", "wp-cli", "woocommerce"
            },
            files = {
              maxSize = 5000000,
            },
            environment = {
              includePaths = {
                "/wordpress/",
                "/wp-content/plugins/",
                "/wp-content/themes/"
              }
            }
          }
        }
      })
      
      -- Other LSP servers (optional, add as needed)
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
      
      -- Keymaps
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })
      
      -- Diagnostic keymaps
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })
    end,
  },
}