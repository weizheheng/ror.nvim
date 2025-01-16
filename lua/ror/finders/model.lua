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
			fzf_opts = {
				["--preview"] = "bat --style=numbers --color=always {}",
				["--preview-window"] = "nohidden,right,60%",
			},
		})
	end
end

return M
