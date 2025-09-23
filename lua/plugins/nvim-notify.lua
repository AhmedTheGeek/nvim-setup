return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		local notify = require("notify")

		notify.setup({
			background_colour = "#000000",
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