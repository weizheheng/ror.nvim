local M = {}

function M.find()
	local fzf = require("fzf-lua")

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
		fzf.fzf_exec(parsed_views, {
			prompt = "Views > ",
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
