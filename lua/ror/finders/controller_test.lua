local M = {}

function M.find()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local previewers = require("telescope.previewers")
	local conf = require("telescope.config").values
	local root_path = vim.fn.getcwd()
	local tests = vim.split(vim.fn.glob(root_path .. "/{test,spec}/controllers/**/*rb"), "\n")
	local parsed_tests = {}
	for _, test in ipairs(tests) do
		-- take only the filename without extension
		if test ~= "" then
			local parsed_test = vim.fn.fnamemodify(test, ":~:.")
			table.insert(parsed_tests, parsed_test)
		end
	end

	if #parsed_tests > 0 then
		local opts = {}
		pickers
			.new(opts, {
				prompt_title = "Controller tests",
				finder = finders.new_table({
					results = parsed_tests,
				}),
				previewer = previewers.vim_buffer_cat.new(opts),
				sorter = conf.generic_sorter(opts),
			})
			:find()
	end
end

return M
