return {
  -- SchemaStore for JSON LSP
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Mason tools installer for formatters and linters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- PHP/Laravel/WordPress
          "php-cs-fixer",     -- PHP formatter
          "phpcs",            -- PHP CodeSniffer
          "phpstan",          -- PHP Static Analysis
          "blade-formatter",  -- Laravel Blade templates

          -- JavaScript/TypeScript
          "prettier",         -- JS/TS/CSS/HTML formatter
          "stylua",          -- Lua formatter

          -- Debug
          "php-debug-adapter", -- PHP debugging
        },
        auto_update = true,
        run_on_start = true,
      })
    end,
  },

  -- Laravel specific support
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
      "nvim-neotest/nvim-nio",  -- Required dependency
    },
    cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    keys = {
      { "<leader>la", ":Laravel artisan<cr>", desc = "Laravel Artisan" },
      { "<leader>lr", ":Laravel routes<cr>", desc = "Laravel Routes" },
      { "<leader>lm", ":Laravel related<cr>", desc = "Laravel Related" },
    },
    event = { "VeryLazy" },
    config = function()
      require("laravel").setup({
        lsp_server = "intelephense",
        features = {
          null_ls = {
            enable = true,
          },
        },
      })
      -- Don't load the telescope extension if it doesn't exist
      local ok, telescope = pcall(require, "telescope")
      if ok then
        pcall(telescope.load_extension, "laravel")
      end
    end,
  },
}