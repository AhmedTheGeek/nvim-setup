return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local colors = {
			bg = "#1e1e2e",
			fg = "#cdd6f4",
			yellow = "#f9e2af",
			cyan = "#89dceb",
			darkblue = "#45475a",
			green = "#a6e3a1",
			orange = "#fab387",
			violet = "#cba6f7",
			magenta = "#f5c2e7",
			blue = "#89b4fa",
			red = "#f38ba8",
			grey = "#6c7086",
			black = "#11111b",
			white = "#ffffff",
		}

		local bubbles_theme = {
			normal = {
				a = { fg = colors.black, bg = colors.violet },
				b = { fg = colors.white, bg = colors.grey },
				c = { fg = colors.white, bg = colors.black },
			},
			insert = { a = { fg = colors.black, bg = colors.blue } },
			visual = { a = { fg = colors.black, bg = colors.cyan } },
			replace = { a = { fg = colors.black, bg = colors.red } },
			inactive = {
				a = { fg = colors.white, bg = colors.black },
				b = { fg = colors.white, bg = colors.black },
				c = { fg = colors.white, bg = colors.black },
			},
		}

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
			local client_names = {}

			for _, client in ipairs(clients) do
				local filetypes = client.config.filetypes
				if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
					table.insert(client_names, client.name)
				end
			end

			if #client_names == 0 then
				return " No LSP"
			end
			return "  " .. table.concat(client_names, ", ")
		end

		local function get_word_count()
			if vim.bo.filetype == "md" or vim.bo.filetype == "txt" or vim.bo.filetype == "markdown" then
				local wc = vim.fn.wordcount()
				return "  " .. wc.words .. " words"
			end
			return ""
		end

		require("lualine").setup({
			options = {
				theme = bubbles_theme,
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
	end,
}