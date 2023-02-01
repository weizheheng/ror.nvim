local M = {}

function M.list_table_columns()
  local root_path = vim.fn.getcwd()
  local create_table_lines = vim.split(vim.fn.system({"grep", "-oE", 'create_table "([^"]*)"', root_path .. "/db/schema.rb"}), "\n")
  local parsed_table_names = {}
  for _, input_string in pairs(create_table_lines) do
    local table_name = string.match(input_string, 'create_table "([^"]*)')
    if table_name then
        table.insert(parsed_table_names, table_name)
    end
  end

  vim.ui.select(
    parsed_table_names,
    {
      prompt = "Which table to list columns?"
    },
    function (selected_table)
      if selected_table ~= nil then
        local awk_command = string.format('/create_table "%s"/{flag=1;next}/end$/{flag=0}flag', selected_table)
        local columns = vim.split(vim.fn.system({ "awk", awk_command, root_path .. "/db/schema.rb" }), "\n")

        local parsed_columns = {}
        for _, column in pairs(columns) do
          if column ~= "" then
            local parsed_column = column:gsub("^%s+", "")
            table.insert(parsed_columns, parsed_column)
          end
        end

        vim.ui.select(
          parsed_columns,
          { prompt = "Available columns for: " .. selected_table },
          function ()
          end
        )
      end
    end
  )
end

return M
