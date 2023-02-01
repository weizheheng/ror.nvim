local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local conf = require("telescope.config").values

function M.visit(mode)
  local current_relative_file_path = vim.fn.expand("%:~:.")

  if string.match(current_relative_file_path, "/controllers") then
    local file_name = vim.fn.fnamemodify(current_relative_file_path, ":t:r")
    local start, _ = string.find(file_name, "_controller")
    local model_name = string.sub(file_name, 1, start - 2) -- Removing the last "s"
    local parsed_model_name = "*" .. model_name .. ".rb"

    local models = vim.split(vim.fn.system({ "find", "app/models", "-name", parsed_model_name }), "\n")
    local parsed_models = {}
    for _, model in pairs(models) do
      if model ~= "" then
        table.insert(parsed_models, model)
      end
    end

    if #parsed_models > 1 then
      local opts = {}
      pickers.new(opts, {
        prompt_title = "Models",
        finder = finders.new_table {
          results = parsed_models
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    elseif #parsed_models == 1 then
      if mode == "normal" then
        vim.cmd.edit(parsed_models[1])
      elseif mode == "vsplit" then
        vim.cmd.vsplit(parsed_models[1])
      end
    else
      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
      if nvim_notify_ok then
        nvim_notify(
          "No model with name: " .. model_name,
          vim.log.levels.ERROR,
          { title = "Model file not found", timeout = 2500 }
        )
      else
        vim.notify("Model file not found")
      end
    end
  elseif string.match(current_relative_file_path, "test/models") then
    local model_name = vim.fn.fnamemodify(current_relative_file_path, ":t:r")
    -- Can go from model test -> controller
    local start, _ = string.find(model_name, "_test")
    if start ~= nil then
      model_name = string.sub(model_name, 1, start - 1)
    end
    local parsed_model_name = "*" .. model_name .. ".rb"

    local models = vim.split(vim.fn.system({ "find", "app/models", "-name", parsed_model_name }), "\n")
    local parsed_models = {}
    for _, model in pairs(models) do
      if model ~= "" then
        table.insert(parsed_models, model)
      end
    end

    if #parsed_models > 1 then
      local opts = {}
      pickers.new(opts, {
        prompt_title = "Models",
        finder = finders.new_table {
          results = parsed_models
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    elseif #parsed_models == 1 then
      if mode == "normal" then
        vim.cmd.edit(parsed_models[1])
      elseif mode == "vsplit" then
        vim.cmd.vsplit(parsed_models[1])
      end
    else
      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
      if nvim_notify_ok then
        nvim_notify(
          "No model with name: " .. model_name,
          vim.log.levels.ERROR,
          { title = "Model file not found", timeout = 2500 }
        )
      else
        vim.notify("Model file not found")
      end
    end
  end
end

return M
