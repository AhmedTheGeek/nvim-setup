return {
  "folke/trouble.nvim",
  opts = {
    -- Configure Trouble to show PHP compatibility warnings prominently
    icons = true,
    fold_open = "▾",
    fold_closed = "▸",
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
    },
    -- Auto open when there are diagnostics
    auto_open = false,
    auto_close = true,
    auto_preview = true,
    auto_fold = false,
    use_diagnostic_signs = true,
  },
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xQ",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
    {
      "<leader>xp",
      "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.WARN<cr>",
      desc = "PHP Compatibility Warnings (Trouble)",
    },
  },
  config = function(_, opts)
    require("trouble").setup(opts)
    
    -- Auto-open Trouble when PHP compatibility issues are detected
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      callback = function()
        local diagnostics = vim.diagnostic.get(0)
        local php_compatibility_issues = false
        
        for _, diagnostic in ipairs(diagnostics) do
          if diagnostic.source == "intelephense" and 
             (diagnostic.message:match("PHP %d+%.%d+") or 
              diagnostic.message:match("deprecated") or
              diagnostic.message:match("not available")) then
            php_compatibility_issues = true
            break
          end
        end
        
        if php_compatibility_issues then
          -- Show a notification about compatibility issues
          vim.notify("PHP compatibility issues detected. Press <leader>xp to view.", vim.log.levels.WARN)
        end
      end,
    })
  end,
}
