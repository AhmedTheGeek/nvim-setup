return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
      vim.keymap.set("n", "<leader>lr", builtin.lsp_references, { desc = "Telescope lsp references" })
      vim.keymap.set("n", "<leader>li", builtin.lsp_implementations, { desc = "Telescope lsp implementations" })
      vim.keymap.set("n", "<leader>lt", builtin.lsp_type_definitions, { desc = "Telescope lsp type definitions" })
      -- vim.keymap.set("n", "<leader>lD", builtin.lsp_declaration, { desc = "Telescope lsp declarations" })
      vim.keymap.set("n", "<leader>ld", builtin.lsp_definitions, { desc = "Telescope lsp definitions" })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              -- even more opts
            }),
          },
        },
      })
      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end,
  },
}
