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

  -- Mason LSPConfig - auto-install LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          -- PHP/Laravel/WordPress
          "intelephense",     -- PHP LSP with Laravel/WP support

          -- JavaScript/TypeScript/React
          "ts_ls",            -- TypeScript/JavaScript
          "eslint",           -- JS/TS linter

          -- Web Development
          "html",             -- HTML
          "cssls",            -- CSS/SCSS/Less
          "tailwindcss",      -- Tailwind CSS IntelliSense
          "emmet_language_server", -- Emmet support
          "jsonls",           -- JSON

          -- Other
          "lua_ls",           -- Lua for Neovim config
          "yamlls",           -- YAML
          "dockerls",         -- Docker
          "docker_compose_language_service", -- Docker Compose
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- PHP Intelephense with Laravel/WordPress support
      lspconfig.intelephense.setup({
        capabilities = capabilities,
        filetypes = { "php", "blade" },
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
              -- WordPress stubs
              "wordpress", "wordpress-globals", "wp-cli", "woocommerce"
            },
            files = {
              maxSize = 5000000,
              associations = {
                "*.php",
                "*.blade.php",
              },
            },
            environment = {
              includePaths = {
                -- Laravel paths
                "./vendor/",
                "./app/",
                "./resources/",
                "./database/",
                -- WordPress paths
                "./wp-content/plugins/",
                "./wp-content/themes/",
                "./wp-includes/"
              },
              phpVersion = "8.2",
            },
            format = {
              enable = false -- We'll use php-cs-fixer instead
            },
            diagnostics = {
              enable = true,
              run = "onType",
            },
            completion = {
              insertUseDeclaration = true,
              fullyQualifyGlobalConstantsAndFunctions = false,
              triggerParameterHints = true,
              maxItems = 100,
            },
          }
        }
      })
      
      -- JavaScript/TypeScript with React support
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      })

      -- ESLint for linting and formatting
      lspconfig.eslint.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      -- CSS/SCSS/Less
      lspconfig.cssls.setup({
        capabilities = capabilities,
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            }
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            }
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            }
          }
        }
      })

      -- Tailwind CSS
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "php" },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "class=\"([^\"]*)\"", 1 },
                { "className=\"([^\"]*)\"", 1 },
                { ":class=\"([^\"]*)\"", 1 },
              },
            },
            validate = true,
          },
        },
      })

      -- HTML with Emmet
      lspconfig.html.setup({
        capabilities = capabilities,
        filetypes = { "html", "php", "blade" },
      })

      -- Emmet
      lspconfig.emmet_language_server.setup({
        capabilities = capabilities,
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "php" },
      })

      -- JSON
      lspconfig.jsonls.setup({
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- YAML
      lspconfig.yamlls.setup({
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
              ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*",
            },
          },
        },
      })

      -- Docker
      lspconfig.dockerls.setup({ capabilities = capabilities })
      lspconfig.docker_compose_language_service.setup({ capabilities = capabilities })

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      })

      
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