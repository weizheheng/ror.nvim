local M = {}

function M.find()
	local fzf = require("fzf-lua")

	local root_path = vim.fn.getcwd()
	local tests = vim.split(vim.fn.glob(root_path .. "/test/system/**/*rb"), "\n")
	local parsed_tests = {}

	for _, test in ipairs(tests) do
		-- take only the filename without extension
		if test ~= "" then
			local parsed_test = vim.fn.fnamemodify(test, ":~:.")
			table.insert(parsed_tests, parsed_test)
		end
	end

	if #parsed_tests > 0 then
		fzf.fzf_exec(parsed_tests, {
			prompt = "Models > ",
			actions = {
				["default"] = function(selected)
					-- Open the selected file
					vim.cmd("edit " .. selected[1])
				end,
			},
			fzf_opts = {
				["--preview"] = "bat --style=numbers --color=always {}",
				["--preview-window"] = "nohidden,right,60%",
			},
		})
	end
end

return M
