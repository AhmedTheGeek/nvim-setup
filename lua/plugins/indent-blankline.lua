return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local hooks = require("ibl.hooks")

		-- Setup highlight groups - use theme colors
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			-- Get colors from current theme
			local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
			local keyword_hl = vim.api.nvim_get_hl(0, { name = "Keyword" })
			local function_hl = vim.api.nvim_get_hl(0, { name = "Function" })

			-- Dim color for inactive indent lines (use comment color but dimmer)
			local dim_color = comment_hl.fg and string.format("#%06x", comment_hl.fg) or "#3B4048"
			-- Bright color for active scope (use keyword or function color)
			local bright_color = (keyword_hl.fg and string.format("#%06x", keyword_hl.fg)) or
			                     (function_hl.fg and string.format("#%06x", function_hl.fg)) or
			                     "#61AFEF"

			vim.api.nvim_set_hl(0, "IblIndent", { fg = dim_color })
			vim.api.nvim_set_hl(0, "IblScope", { fg = bright_color })
		end)

		-- Refresh indent colors when colorscheme changes
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				-- Re-apply theme colors
				local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
				local keyword_hl = vim.api.nvim_get_hl(0, { name = "Keyword" })
				local function_hl = vim.api.nvim_get_hl(0, { name = "Function" })

				local dim_color = comment_hl.fg and string.format("#%06x", comment_hl.fg) or "#3B4048"
				local bright_color = (keyword_hl.fg and string.format("#%06x", keyword_hl.fg)) or
				                     (function_hl.fg and string.format("#%06x", function_hl.fg)) or
				                     "#61AFEF"

				vim.api.nvim_set_hl(0, "IblIndent", { fg = dim_color })
				vim.api.nvim_set_hl(0, "IblScope", { fg = bright_color })
				require("ibl").refresh()
			end
		})

		-- Simple approach: use scope for current context
		require("ibl").setup({
			indent = {
				highlight = "IblIndent",
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
				highlight = "IblScope",
				include = {
					node_type = {
						["*"] = { "*" },
					},
				},
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