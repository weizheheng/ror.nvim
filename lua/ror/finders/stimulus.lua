local M = {}

function M.find()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local previewers = require "telescope.previewers"
  local conf = require("telescope.config").values
  local root_path = vim.fn.getcwd()
  local stimulus_controllers = vim.split(vim.fn.glob(root_path .. "/app/javascript/controllers/*js"), "\n")
  local parsed_stimulus_controllers = {}
  for _, stimulus_controller in ipairs(stimulus_controllers) do
    -- take only the filename without extension
    if stimulus_controller ~= "" then
      local parsed_stimulus_controller = vim.fn.fnamemodify(stimulus_controller, ":~:.")
      table.insert(parsed_stimulus_controllers, parsed_stimulus_controller)
    end
  end

  if #parsed_stimulus_controllers > 0 then
    local opts = {}
    pickers.new(opts, {
      prompt_title = "System tests",
      finder = finders.new_table {
        results = parsed_stimulus_controllers
      },
      previewer = previewers.vim_buffer_cat.new(opts),
      sorter = conf.generic_sorter(opts),
    }):find()
  end
end

return M
