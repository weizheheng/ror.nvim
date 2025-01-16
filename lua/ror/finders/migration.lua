local M = {}

function M.find()
	local fzf = require("fzf-lua")

	local root_path = vim.fn.getcwd()
	local migrations = vim.split(vim.fn.glob(root_path .. "/db/migrate/*rb"), "\n")
	local parsed_migrations = {}
	for i = #migrations, 1, -1 do
		if migrations[i] ~= "" then
			-- take only the filename without extension
			local parsed_filename = vim.fn.fnamemodify(migrations[i], ":~:.")
			table.insert(parsed_migrations, parsed_filename)
		end
	end

	if #parsed_migrations > 0 then
		fzf.fzf_exec(parsed_migrations, {
			prompt = "Migrations > ",
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
