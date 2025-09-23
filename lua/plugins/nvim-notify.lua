return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		local notify = require("notify")

		-- Function to get theme-appropriate colors
		local function get_theme_colors()
			local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
			local error_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticError" })
			local warn_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" })
			local info_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" })
			local hint_hl = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" })

			-- Get background color from Normal highlight or fallback
			local bg_color = normal_hl.bg and string.format("#%06x", normal_hl.bg) or "#000000"

			return {
				background = bg_color,
				error = error_hl.fg and string.format("#%06x", error_hl.fg) or "#E06C75",
				warn = warn_hl.fg and string.format("#%06x", warn_hl.fg) or "#E5C07B",
				info = info_hl.fg and string.format("#%06x", info_hl.fg) or "#61AFEF",
				hint = hint_hl.fg and string.format("#%06x", hint_hl.fg) or "#98C379",
			}
		end

		local colors = get_theme_colors()

		notify.setup({
			background_colour = colors.background,
			fps = 60,
			icons = {
				DEBUG = "",
				ERROR = "",
				INFO = "",
				TRACE = "✎",
				WARN = "",
			},
			level = 2,
			minimum_width = 50,
			render = "compact",
			stages = "fade_in_slide_out",
			time_formats = {
				notification = "%T",
				notification_history = "%FT%T",
			},
			timeout = 3000,
			top_down = true,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
		})

		vim.notify = notify

		-- Set up theme-based highlight groups
		local function setup_notify_highlights()
			local colors = get_theme_colors()

			-- Define notify highlight groups based on theme
			vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = colors.error })
			vim.api.nvim_set_hl(0, "NotifyERRORIcon", { fg = colors.error })
			vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = colors.error })

			vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = colors.warn })
			vim.api.nvim_set_hl(0, "NotifyWARNIcon", { fg = colors.warn })
			vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = colors.warn })

			vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = colors.info })
			vim.api.nvim_set_hl(0, "NotifyINFOIcon", { fg = colors.info })
			vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = colors.info })

			vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = colors.hint })
			vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", { fg = colors.hint })
			vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = colors.hint })

			vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = colors.hint })
			vim.api.nvim_set_hl(0, "NotifyTRACEIcon", { fg = colors.hint })
			vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = colors.hint })

			-- Update background color
			notify.setup({ background_colour = colors.background })
		end

		setup_notify_highlights()

		-- Refresh notify colors when colorscheme changes
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				setup_notify_highlights()
			end
		})

		local banned_messages = {
			"No information available",
			"LSP[tsserver] Inlay Hints request failed",
			"LSP[tailwindcss] Inlay Hints request failed",
		}

		vim.notify = function(msg, level, opts)
			for _, banned_msg in ipairs(banned_messages) do
				if msg == banned_msg then
					return
				end
			end
			return notify(msg, level, opts)
		end

		vim.keymap.set("n", "<leader>un", function()
			require("notify").dismiss({ silent = true, pending = true })
		end, { desc = "Dismiss All Notifications" })

		vim.keymap.set("n", "<leader>fn", function()
			require("telescope").extensions.notify.notify()
		end, { desc = "Find Notifications" })

		local function get_notification_icon()
			local history = require("notify").history()
			if #history == 0 then
				return ""
			end

			local recent = history[#history]
			if not recent then
				return ""
			end

			local level_icons = {
				["ERROR"] = " ",
				["WARN"] = " ",
				["INFO"] = " ",
				["DEBUG"] = " ",
				["TRACE"] = " ",
			}

			return level_icons[recent.level] or " "
		end

		_G.get_notification_status = function()
			local history = require("notify").history()
			if #history == 0 then
				return ""
			end

			local counts = {
				ERROR = 0,
				WARN = 0,
				INFO = 0,
			}

			for _, notif in ipairs(history) do
				if counts[notif.level] then
					counts[notif.level] = counts[notif.level] + 1
				end
			end

			local parts = {}
			if counts.ERROR > 0 then
				table.insert(parts, string.format(" %d", counts.ERROR))
			end
			if counts.WARN > 0 then
				table.insert(parts, string.format(" %d", counts.WARN))
			end
			if counts.INFO > 0 then
				table.insert(parts, string.format(" %d", counts.INFO))
			end

			if #parts > 0 then
				return " " .. table.concat(parts, " ")
			end
			return ""
		end
	end,
}