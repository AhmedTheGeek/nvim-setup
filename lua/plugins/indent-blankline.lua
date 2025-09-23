return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local hooks = require("ibl.hooks")

		-- Setup dim indent lines and highlighted scope
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			-- Dim indent lines (use a subtle gray)
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3B4048" })

			-- Highlighted scope colors for current indent level
			vim.api.nvim_set_hl(0, "IblScopeRed", { fg = "#E06C75" })
			vim.api.nvim_set_hl(0, "IblScopeYellow", { fg = "#E5C07B" })
			vim.api.nvim_set_hl(0, "IblScopeBlue", { fg = "#61AFEF" })
			vim.api.nvim_set_hl(0, "IblScopeOrange", { fg = "#D19A66" })
			vim.api.nvim_set_hl(0, "IblScopeGreen", { fg = "#98C379" })
			vim.api.nvim_set_hl(0, "IblScopeViolet", { fg = "#C678DD" })
			vim.api.nvim_set_hl(0, "IblScopeCyan", { fg = "#56B6C2" })
		end)

		require("ibl").setup({
			indent = {
				-- Use dim highlight for all indent lines
				highlight = "IblIndent",
				char = "│",
				tab_char = "│",
			},
			scope = {
				-- Enable scope highlighting for current indent level
				enabled = true,
				show_start = true,
				show_end = false,
				injected_languages = true,
				-- Use colored highlights for the current scope
				highlight = {
					"IblScopeRed",
					"IblScopeYellow",
					"IblScopeBlue",
					"IblScopeOrange",
					"IblScopeGreen",
					"IblScopeViolet",
					"IblScopeCyan",
				},
				priority = 500,
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
				},
			},
		})
	end,
}