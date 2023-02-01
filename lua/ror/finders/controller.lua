local M = {}

function M.find()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local previewers = require "telescope.previewers"
  local conf = require("telescope.config").values
  local root_path = vim.fn.getcwd()
  local controllers = vim.split(vim.fn.glob(root_path .. "/app/controllers/**/*rb"), "\n")
  local parsed_controllers = {}
  for _, value in ipairs(controllers) do
    -- take only the filename without extension
    if value ~= "" then
      local parsed_filename = vim.fn.fnamemodify(value, ":~:.")
      table.insert(parsed_controllers, parsed_filename)
    end
  end

  local opts = {}
  pickers.new(opts, {
    prompt_title = "Controllers",
    finder = finders.new_table {
      results = parsed_controllers
    },
    previewer = previewers.vim_buffer_cat.new(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
