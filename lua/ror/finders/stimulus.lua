local M = {}

function M.find()
	local fzf = require("fzf-lua")

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
		fzf.fzf_exec(parsed_stimulus_controllers, {
			prompt = "Stimulus controllers > ",
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
