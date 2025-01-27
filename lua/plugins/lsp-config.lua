return  { {"williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
          ensure_installed = { "lua_ls", "intelephense", "ts_ls", "cssls", "ts_ls", "vuels", "html", "yamlls", "dockerls", "cmake", "terraformls"}
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      lspconfig.lua_ls.setup({capabilities = capabilities})
      lspconfig.intelephense.setup({capabilities = capabilities})
      lspconfig.ts_ls.setup({capabilities = capabilities})
      lspconfig.cssls.setup({capabilities = capabilities})
      lspconfig.vuels.setup({capabilities = capabilities})
      lspconfig.html.setup({capabilities = capabilities})
      lspconfig.yamlls.setup({capabilities = capabilities})
      lspconfig.dockerls.setup({capabilities = capabilities})
      lspconfig.cmake.setup({capabilities = capabilities})
      lspconfig.terraformls.setup({capabilities = capabilities})
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end
  },
  {
    "bitpoke/wordpress.nvim",
    config = function()
      local wp = require('wordpress')
      local lspconfig = require('lspconfig')

      -- setup intelephense for PHP, WordPress and WooCommerce development
      lspconfig.intelephense.setup(wp.intelephense)

    end
  },
}
