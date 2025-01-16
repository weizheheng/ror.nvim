local M = {}

function M.find()
	local fzf = require("fzf-lua")

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

	if #parsed_mailers > 0 then
		fzf.fzf_exec(parsed_mailers, {
			prompt = "Mailers > ",
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
