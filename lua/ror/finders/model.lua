-- local M = {}
--
-- function M.find()
--   local pickers = require "telescope.pickers"
--   local finders = require "telescope.finders"
--   local previewers = require "telescope.previewers"
--   local conf = require("telescope.config").values
--
--   local root_path = vim.fn.getcwd()
--   local models = vim.split(vim.fn.glob(root_path .. "/app/models/**/*rb"), "\n")
--   local parsed_models = {}
--   for _, value in ipairs(models) do
--     -- take only the filename without extension
--     if value ~= "" then
--       local parsed_filename = vim.fn.fnamemodify(value, ":~:.")
--       table.insert(parsed_models, parsed_filename)
--     end
--   end
--
--   if #parsed_models > 0 then
--     local opts = {}
--     pickers.new(opts, {
--       prompt_title = "Models",
--       finder = finders.new_table {
--         results = parsed_models
--       },
--       previewer = previewers.vim_buffer_cat.new(opts),
--       sorter = conf.generic_sorter(opts),
--     }):find()
--   end
-- end
--
-- return M
local M = {}

function M.find()
	local fzf = require("fzf-lua")

	local root_path = vim.fn.getcwd()
	local models = vim.split(vim.fn.glob(root_path .. "/app/models/**/*rb"), "\n")
	local parsed_models = {}

	for _, value in ipairs(models) do
		if value ~= "" then
			local parsed_filename = vim.fn.fnamemodify(value, ":~:.")
			table.insert(parsed_models, parsed_filename)
		end
	end

	if #parsed_models > 0 then
		fzf.fzf_exec(parsed_models, {
			prompt = "Models > ",
			actions = {
				["default"] = function(selected)
					-- Open the selected file
					vim.cmd("edit " .. selected[1])
				end,
			},
			previewer = "builtin", -- Use the built-in file previewer
			winopts = {
				height = 0.8, -- Window height (80% of screen)
				width = 0.8, -- Window width (80% of screen)
				preview = {
					hidden = "hidden", -- Show preview by default
				},
			},
		})
	end
end

return M
