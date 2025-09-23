-- Omarchy theme integration
-- This plugin reads the Omarchy theme configuration and applies the colorscheme
-- It also loads any required colorscheme plugins

local M = {}

local function get_omarchy_config()
  local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
  if vim.fn.filereadable(theme_file) == 1 then
    local ok, theme_config = pcall(dofile, theme_file)
    if ok and theme_config then
      return theme_config
    end
  end
  return {}
end

local function get_omarchy_colorscheme()
  local config = get_omarchy_config()
  -- Extract the colorscheme from Omarchy's theme config
  for _, plugin in ipairs(config) do
    if type(plugin) == "table" and plugin[1] == "LazyVim/LazyVim" and plugin.opts and plugin.opts.colorscheme then
      return plugin.opts.colorscheme
    end
  end
  return nil
end

local function get_theme_plugins()
  local config = get_omarchy_config()
  local plugins = {}
  -- Extract theme plugins (not LazyVim itself)
  for _, plugin in ipairs(config) do
    if type(plugin) == "table" and plugin[1] ~= "LazyVim/LazyVim" then
      table.insert(plugins, plugin)
    end
  end
  return plugins
end

local function apply_omarchy_theme()
  local colorscheme = get_omarchy_colorscheme()
  if colorscheme then
    -- Try to apply the colorscheme, fall back if it doesn't exist
    local ok, err = pcall(vim.cmd, "colorscheme " .. colorscheme)
    if not ok then
      vim.notify("Colorscheme '" .. colorscheme .. "' not found. Install the theme plugin or use a different Omarchy theme.", vim.log.levels.WARN)
      -- Try to fall back to a default colorscheme
      pcall(vim.cmd, "colorscheme default")
    end
  end
end

-- Watch for theme changes
local function watch_theme_changes()
  local timer = vim.loop.new_timer()
  local theme_link = vim.fn.expand("~/.config/omarchy/current/theme")
  local last_target = vim.fn.resolve(theme_link)

  timer:start(1000, 1000, vim.schedule_wrap(function()
    local current_target = vim.fn.resolve(theme_link)
    if current_target ~= last_target then
      last_target = current_target
      -- Theme changed, apply new colorscheme
      apply_omarchy_theme()
      vim.notify("Omarchy theme switched to: " .. (get_omarchy_colorscheme() or "unknown"), vim.log.levels.INFO)
    end
  end))
end

-- Set up autocmd to apply theme and start watching
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    apply_omarchy_theme()
    watch_theme_changes()
  end
})

-- Return the theme plugins from Omarchy config so Lazy can load them
return get_theme_plugins()