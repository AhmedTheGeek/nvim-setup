return {
  "voldikss/vim-floaterm",
  config = function()
    vim.keymap.set("n", "<leader>ft", "<cmd>FloatermNew --wintype=float<cr>")
    vim.keymap.set("n", "<leader>fs", "<cmd>FloatermNew --wintype=split<cr>")
    vim.keymap.set("n", "<leader>fv", "<cmd>FloatermNew --wintype=vsplit<cr>")
    vim.keymap.set("n", "<leader>tt", "<cmd>FloatermToggle<cr>")
  end,
}
