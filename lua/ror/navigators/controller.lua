local M = {}

function M.visit(mode)
  local current_relative_file_path = vim.fn.expand("%:~:.")

  if string.match(current_relative_file_path, "/models") then
    local model_name = vim.fn.fnamemodify(current_relative_file_path, ":t:r")
    -- Can go from model test -> controller
    local start, _ = string.find(model_name, "_test")
    if start ~= nil then
      model_name = string.sub(model_name, 1, start - 1)
    end
    -- Rails default of pluralizing controller
    -- Caveat: not working with controller with pluralize name other than adding s
    local parsed_controller_name = "*" .. model_name .. "s_controller.rb"

    local controllers = vim.split(vim.fn.system({ "find", "app/controllers", "-name", parsed_controller_name }), "\n")
    local parsed_controllers = {}
    for _, controller in pairs(controllers) do
      if controller ~= "" then
        table.insert(parsed_controllers, controller)
      end
    end

    if #parsed_controllers > 1 then
      local pickers = require "telescope.pickers"
      local finders = require "telescope.finders"
      local previewers = require "telescope.previewers"
      local conf = require("telescope.config").values
      local opts = {}
      pickers.new(opts, {
        prompt_title = "Controllers",
        finder = finders.new_table {
          results = parsed_controllers
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    elseif #parsed_controllers == 1 then
      if mode == "normal" then
        vim.cmd.edit(parsed_controllers[1])
      elseif mode == "vsplit" then
        vim.cmd.vsplit(parsed_controllers[1])
      end
    else
      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
      if nvim_notify_ok then
        nvim_notify(
          "No controller with name: " .. parsed_controller_name,
          vim.log.levels.ERROR,
          { title = "Controller file not found", timeout = 2500 }
        )
      else
        vim.notify("Controller file not found")
      end
    end
  elseif string.match(current_relative_file_path, "test/controllers") then
    local controller_name = vim.fn.fnamemodify(current_relative_file_path, ":t:r")
    -- Can go from controller test -> controller
    local start, _ = string.find(controller_name, "_test")
    if start ~= nil then
      controller_name = string.sub(controller_name, 1, start - 1)
    end
    local parsed_controller_name = "*" .. controller_name .. ".rb"

    local controllers = vim.split(vim.fn.system({ "find", "app/controllers", "-name", parsed_controller_name }), "\n")
    local parsed_controllers = {}
    for _, controller in pairs(controllers) do
      if controller ~= "" then
        table.insert(parsed_controllers, controller)
      end
    end

    if #parsed_controllers > 1 then
      local pickers = require "telescope.pickers"
      local finders = require "telescope.finders"
      local previewers = require "telescope.previewers"
      local conf = require("telescope.config").values
      local opts = {}
      pickers.new(opts, {
        prompt_title = "Controllers",
        finder = finders.new_table {
          results = parsed_controllers
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    elseif #parsed_controllers == 1 then
      if mode == "normal" then
        vim.cmd.edit(parsed_controllers[1])
      elseif mode == "vsplit" then
        vim.cmd.vsplit(parsed_controllers[1])
      end
    else
      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
      if nvim_notify_ok then
        nvim_notify(
          "No controller with name: " .. parsed_controller_name,
          vim.log.levels.ERROR,
          { title = "Controller file not found", timeout = 2500 }
        )
      else
        vim.notify("Controller file not found")
      end
    end
  end
end

return M
