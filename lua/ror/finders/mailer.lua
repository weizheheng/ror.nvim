local M = {}

function M.find()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local previewers = require "telescope.previewers"
  local conf = require("telescope.config").values
  local root_path = vim.fn.getcwd()
  local mailers = vim.split(vim.fn.glob(root_path .. "/app/mailers/**/*rb"), "\n")
  local parsed_mailers = {}
  for _, value in ipairs(mailers) do
    -- take only the filename without extension
    if value ~= "" then
      local parsed_filename = vim.fn.fnamemodify(value, ":~:.")
      table.insert(parsed_mailers, parsed_filename)
    end
  end

  local opts = {}
  pickers.new(opts, {
    prompt_title = "Mailers",
    finder = finders.new_table {
      results = parsed_mailers
    },
    previewer = previewers.vim_buffer_cat.new(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
