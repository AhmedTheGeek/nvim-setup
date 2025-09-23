return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Function to get colors from current theme
		local function get_theme_colors()
			local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
			local keyword_hl = vim.api.nvim_get_hl(0, { name = "Keyword" })
			local function_hl = vim.api.nvim_get_hl(0, { name = "Function" })
			local string_hl = vim.api.nvim_get_hl(0, { name = "String" })
			local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
			local constant_hl = vim.api.nvim_get_hl(0, { name = "Constant" })
			local identifier_hl = vim.api.nvim_get_hl(0, { name = "Identifier" })
			local type_hl = vim.api.nvim_get_hl(0, { name = "Type" })
			local special_hl = vim.api.nvim_get_hl(0, { name = "Special" })
			local error_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticError" })
			local warn_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" })
			local info_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" })
			local hint_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" })

			return {
				bg = normal_hl.bg and string.format("#%06x", normal_hl.bg) or "#1e1e2e",
				fg = normal_hl.fg and string.format("#%06x", normal_hl.fg) or "#cdd6f4",
				yellow = warn_hl.fg and string.format("#%06x", warn_hl.fg) or "#f9e2af",
				cyan = info_hl.fg and string.format("#%06x", info_hl.fg) or "#89dceb",
				darkblue = comment_hl.fg and string.format("#%06x", comment_hl.fg) or "#45475a",
				green = string_hl.fg and string.format("#%06x", string_hl.fg) or "#a6e3a1",
				orange = constant_hl.fg and string.format("#%06x", constant_hl.fg) or "#fab387",
				violet = keyword_hl.fg and string.format("#%06x", keyword_hl.fg) or "#cba6f7",
				magenta = special_hl.fg and string.format("#%06x", special_hl.fg) or "#f5c2e7",
				blue = function_hl.fg and string.format("#%06x", function_hl.fg) or "#89b4fa",
				red = error_hl.fg and string.format("#%06x", error_hl.fg) or "#f38ba8",
				grey = comment_hl.fg and string.format("#%06x", comment_hl.fg) or "#6c7086",
				black = normal_hl.bg and string.format("#%06x", normal_hl.bg) or "#11111b",
				white = normal_hl.fg and string.format("#%06x", normal_hl.fg) or "#ffffff",
			}
		end

		local colors = get_theme_colors()

		local function create_theme()
			local c = get_theme_colors()
			return {
				normal = {
					a = { fg = c.black, bg = c.violet },
					b = { fg = c.white, bg = c.grey },
					c = { fg = c.white, bg = c.black },
				},
				insert = { a = { fg = c.black, bg = c.blue } },
				visual = { a = { fg = c.black, bg = c.cyan } },
				replace = { a = { fg = c.black, bg = c.red } },
				inactive = {
					a = { fg = c.white, bg = c.black },
					b = { fg = c.white, bg = c.black },
					c = { fg = c.white, bg = c.black },
				},
			}
		end

		local bubbles_theme = create_theme()

		local function get_venv()
			local venv = vim.env.VIRTUAL_ENV
			if venv then
				local venv_name = vim.fn.fnamemodify(venv, ":t")
				return "  " .. venv_name
			end
			return ""
		end

		local function get_cwd()
			local cwd = vim.fn.getcwd()
			local home = vim.env.HOME
			if cwd:find(home, 1, true) == 1 then
				cwd = "~" .. cwd:sub(#home + 1)
			end
			return "  " .. vim.fn.fnamemodify(cwd, ":t")
		end

		local function lsp_progress()
			local lsp = vim.lsp.util.get_progress_messages()[1]
			if lsp then
				local name = lsp.name or ""
				local msg = lsp.message or ""
				local percentage = lsp.percentage or 0
				local title = lsp.title or ""
				return string.format(" %%<%s: %s %s (%s%%%%) ", name, title, msg, percentage)
			end
			return ""
		end

		local function get_tabs_count()
			local num_tabs = #vim.api.nvim_list_tabpages()
			if num_tabs > 1 then
				local current_tab = vim.api.nvim_get_current_tabpage()
				local tab_num = 0
				for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
					if tab == current_tab then
						tab_num = i
						break
					end
				end
				return "  " .. tab_num .. "/" .. num_tabs
			end
			return ""
		end

		local function macro_recording()
			local reg = vim.fn.reg_recording()
			if reg ~= "" then
				return "  Recording @" .. reg
			end
			return ""
		end

		local function search_count()
			if vim.v.hlsearch == 0 then
				return ""
			end
			local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 250 })
			if not ok or result.current == nil or result.total == 0 then
				return ""
			end
			if result.incomplete == 1 then
				return " ?/?? "
			end
			local current = result.current
			local total = result.total
			return string.format("  %d/%d ", current, total)
		end

		local function get_lsp_clients()
			local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
			local clients = vim.lsp.get_clients()
			local active_count = 0

			for _, client in ipairs(clients) do
				local filetypes = client.config.filetypes
				if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
					active_count = active_count + 1
				end
			end

			if active_count == 0 then
				return " No LSP"
			elseif active_count == 1 then
				return "  LSP"
			else
				return "  " .. active_count .. " LSP"
			end
		end

		local function get_word_count()
			if vim.bo.filetype == "md" or vim.bo.filetype == "txt" or vim.bo.filetype == "markdown" then
				local wc = vim.fn.wordcount()
				return "  " .. wc.words .. " words"
			end
			return ""
		end

		local lualine = require("lualine")

		lualine.setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = {
					{
						function()
							local mode_map = {
								["n"] = "NORMAL",
								["no"] = "NORMAL",
								["nov"] = "NORMAL",
								["noV"] = "NORMAL",
								["no\22"] = "NORMAL",
								["niI"] = "NORMAL",
								["niR"] = "NORMAL",
								["niV"] = "NORMAL",
								["nt"] = "NORMAL",
								["ntT"] = "NORMAL",
								["v"] = "VISUAL",
								["vs"] = "VISUAL",
								["V"] = "V-LINE",
								["Vs"] = "V-LINE",
								["\22"] = "V-BLOCK",
								["\22s"] = "V-BLOCK",
								["s"] = "SELECT",
								["S"] = "S-LINE",
								["\19"] = "S-BLOCK",
								["i"] = "INSERT",
								["ic"] = "INSERT",
								["ix"] = "INSERT",
								["R"] = "REPLACE",
								["Rc"] = "REPLACE",
								["Rx"] = "REPLACE",
								["Rv"] = "V-REPLACE",
								["Rvc"] = "V-REPLACE",
								["Rvx"] = "V-REPLACE",
								["c"] = "COMMAND",
								["cv"] = "EX",
								["ce"] = "EX",
								["r"] = "REPLACE",
								["rm"] = "MORE",
								["r?"] = "CONFIRM",
								["!"] = "SHELL",
								["t"] = "TERMINAL",
							}
							local mode = vim.fn.mode()
							return " " .. (mode_map[mode] or mode)
						end,
						separator = { left = "", right = "" },
						padding = { left = 1, right = 1 },
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "",
						separator = { left = "", right = "" },
						padding = { left = 1, right = 1 },
					},
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = {
							added = { fg = colors.green },
							modified = { fg = colors.orange },
							removed = { fg = colors.red },
						},
						separator = { right = "" },
					},
				},
				lualine_c = {
					{ get_cwd, color = { fg = colors.cyan, gui = "bold" } },
					{
						"filename",
						file_status = true,
						newfile_status = true,
						path = 1,
						symbols = {
							modified = " ●",
							readonly = " ",
							unnamed = " [No Name]",
							newfile = " ",
						},
						color = { fg = colors.magenta, gui = "bold" },
					},
					{ macro_recording, color = { fg = colors.red, gui = "bold" } },
					{ search_count, color = { fg = colors.orange } },
					{ get_word_count, color = { fg = colors.grey } },
					{ lsp_progress, color = { fg = colors.yellow } },
				},
				lualine_x = {
					{
						function()
							return _G.get_notification_status and _G.get_notification_status() or ""
						end,
						color = { fg = colors.yellow },
					},
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						diagnostics_color = {
							error = { fg = colors.red },
							warn = { fg = colors.yellow },
							info = { fg = colors.cyan },
							hint = { fg = colors.blue },
						},
					},
					{ get_lsp_clients, color = { fg = colors.violet, gui = "bold" } },
					{ get_venv, color = { fg = colors.green } },
					{
						"filetype",
						colored = true,
						icon_only = false,
						icon = { align = "left" },
						color = { gui = "bold" },
					},
				},
				lualine_y = {
					{
						"encoding",
						separator = { left = "" },
						padding = { left = 1, right = 0 },
					},
					{
						"fileformat",
						symbols = {
							unix = "LF",
							dos = "CRLF",
							mac = "CR",
						},
						separator = { right = "" },
						padding = { left = 0, right = 1 },
					},
				},
				lualine_z = {
					{
						function()
							local line = vim.fn.line(".")
							local col = vim.fn.virtcol(".")
							local total_lines = vim.fn.line("$")
							local percent = math.floor(line / total_lines * 100)
							return string.format(" %d:%d | %d%%%% ", line, col, percent)
						end,
						separator = { left = "", right = "" },
					},
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " ●",
							readonly = " ",
							unnamed = " [No Name]",
						},
					},
				},
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
						show_filename_only = true,
						hide_filename_extension = false,
						show_modified_status = true,
						mode = 2,
						max_length = vim.o.columns * 2 / 3,
						filetype_names = {
							TelescopePrompt = " Telescope",
							dashboard = " Dashboard",
							fzf = " FZF",
						},
						symbols = {
							modified = " ●",
							alternate_file = "",
							directory = " ",
						},
						separator = { left = "", right = "" },
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = { get_tabs_count },
				lualine_z = {
					{
						"datetime",
						style = " %H:%M",
						separator = { left = "", right = "" },
					},
				},
			},
			extensions = { "fugitive", "nvim-tree", "quickfix", "trouble", "lazy" },
		})

		-- Refresh lualine when colorscheme changes
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				vim.schedule(function()
					-- Update colors variable for components
					colors = get_theme_colors()
					-- Just refresh with auto theme
					require("lualine").refresh()
				end)
			end
		})
	end,
}