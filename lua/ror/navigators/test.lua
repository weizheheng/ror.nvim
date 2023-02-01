local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local conf = require("telescope.config").values

function M.visit(mode)
  local current_relative_file_path = vim.fn.expand("%:~:.")

  if string.match(current_relative_file_path, "app/models") then
    local model_name = vim.fn.fnamemodify(current_relative_file_path, ":t:r")
    local test_name = model_name .. "_test.rb"

    local tests = vim.split(vim.fn.system({ "find", "test/models", "-name", test_name }), "\n")
    local parsed_tests = {}
    for _, test in pairs(tests) do
      if test ~= "" then
        table.insert(parsed_tests, test)
      end
    end

    if #parsed_tests > 1 then
      local opts = {}
      pickers.new(opts, {
        prompt_title = "Model Tests",
        finder = finders.new_table {
          results = parsed_tests
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    elseif #parsed_tests == 1 then
      if mode == "normal" then
        vim.cmd.edit(parsed_tests[1])
      elseif mode == "vsplit" then
        vim.cmd.vsplit(parsed_tests[1])
      end
    else
      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
      if nvim_notify_ok then
        nvim_notify(
          "No test with name: " .. test_name,
          vim.log.levels.ERROR,
          { title = "Test file not found", timeout = 2500 }
        )
      else
        vim.notify("Test file not found")
      end
    end
  elseif string.match(current_relative_file_path, "app/controllers") then
    local controller_name = vim.fn.fnamemodify(current_relative_file_path, ":t:r")
    local test_name = controller_name .. "_test.rb"

    local tests = vim.split(vim.fn.system({ "find", "test/controllers", "-name", test_name }), "\n")
    local parsed_tests = {}
    for _, test in pairs(tests) do
      if test ~= "" then
        table.insert(parsed_tests, test)
      end
    end

    if #parsed_tests > 1 then
      local opts = {}
      pickers.new(opts, {
        prompt_title = "Controller Tests",
        finder = finders.new_table {
          results = parsed_tests
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    elseif #parsed_tests == 1 then
      if mode == "normal" then
        vim.cmd.edit(parsed_tests[1])
      elseif mode == "vsplit" then
        vim.cmd.vsplit(parsed_tests[1])
      end
    else
      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
      if nvim_notify_ok then
        nvim_notify(
          "No test with name: " .. test_name,
          vim.log.levels.ERROR,
          { title = "Test file not found", timeout = 2500 }
        )
      else
        vim.notify("Test file not found")
      end
    end
  end
end

return M
