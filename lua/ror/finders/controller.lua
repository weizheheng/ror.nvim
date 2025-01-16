local M = {}

function M.find()
	local fzf = require("fzf-lua")

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

	if #parsed_controllers > 0 then
		fzf.fzf_exec(parsed_controllers, {
			prompt = "Controllers > ",
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
