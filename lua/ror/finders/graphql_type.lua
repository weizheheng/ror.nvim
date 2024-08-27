local M = {}

function M.find()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local previewers = require("telescope.previewers")
	local conf = require("telescope.config").values

	local root_path = vim.fn.getcwd()
	local models = vim.split(vim.fn.glob(root_path .. "/app/graphql/types/**/*rb"), "\n")
	local parsed_models = {}
	for _, value in ipairs(models) do
		-- take only the filename without extension
		if value ~= "" then
			local parsed_filename = vim.fn.fnamemodify(value, ":~:.")
			table.insert(parsed_models, parsed_filename)
		end
	end

	if #parsed_models > 0 then
		local opts = {}
		pickers
			.new(opts, {
				prompt_title = "Graphql Types",
				finder = finders.new_table({
					results = parsed_models,
				}),
				previewer = previewers.vim_buffer_cat.new(opts),
				sorter = conf.generic_sorter(opts),
			})
			:find()
	end
end

return M
