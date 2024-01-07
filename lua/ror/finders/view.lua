local M = {}

function M.find()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local previewers = require "telescope.previewers"
  local conf = require("telescope.config").values
  local root_path = vim.fn.getcwd()
  local views = vim.split(vim.fn.glob(root_path .. "/app/views/**/*.erb"), "\n")
  local parsed_views = {}
  for _, view in ipairs(views) do
    -- take only the filename without extension
    if view ~= "" then
      local parsed_view = vim.fn.fnamemodify(view, ":~:.")
      table.insert(parsed_views, parsed_view)
    end
  end

  if #parsed_views > 0 then
    local opts = {}
    pickers.new(opts, {
        prompt_title = "Views",
        finder = finders.new_table {
          results = parsed_views
        },
        previewer = previewers.vim_buffer_cat.new(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
  end
end

return M
