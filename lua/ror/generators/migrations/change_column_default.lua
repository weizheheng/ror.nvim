local Path = require("plenary.path")

local M = {}

function M.run(close_floating_window)
  local root_path = vim.fn.getcwd()
  local create_table_lines = vim.split(vim.fn.system({"grep", "-oE", 'create_table "([^"]*)"', root_path .. "/db/schema.rb"}), "\n")
  local parsed_table_names = {}

  for _, input_string in pairs(create_table_lines) do
    local table_name = string.match(input_string, 'create_table "([^"]*)')
    if table_name then
        table.insert(parsed_table_names, table_name)
    end
  end

  vim.ui.select(parsed_table_names, { prompt = "Changing column default for which table?" }, function(selected_table)
    if selected_table ~= nil then
      local awk_command = string.format('/create_table "%s"/{flag=1;next}/end$/{flag=0}flag', selected_table)
      local columns = vim.split(vim.fn.system({ "awk", awk_command, root_path .. "/db/schema.rb" }), "\n")
      local parsed_columns = {}
      for _, column in pairs(columns) do
        if column ~= "" and string.match(column, "default:") then
          local parsed_column = string.match(column, "^%s*(.*)$")
          table.insert(parsed_columns, parsed_column)
        end
      end

      vim.ui.select(
        parsed_columns,
        { prompt = "Changing which column's default value?" },
        function (selected_column)
          if selected_column ~= nil then
            local column_name = string.match(selected_column, 't%.%w+%s+"([^"]+)')
            local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

            local migration_name = "change_" .. column_name .. "_default_in_" .. selected_table
            local command = { "bin/rails", "generate", "migration", migration_name }
            if nvim_notify_ok then
              nvim_notify(
                "Command: bin/rails generate migration " .. migration_name,
                "warn",
                { title = "Generating migration...", timeout = false }
              )
            else
              vim.notify("Generating migration...")
            end

            vim.fn.jobstart(command, {
              stdout_buffered = true,
              on_stdout = function(_, data)
                if not data then
                  return
                end

                local parsed_data = {}
                for i, v in ipairs(data) do
                  if v ~= "" then
                    parsed_data[i] = string.gsub(v, '^%s*(.-)%s*$', '%1')
                  end
                end
                local file_created = string.gsub(parsed_data[2], "create    ", "")

                local file_content = vim.split(Path:new(file_created):read(), "\n")
                local active_record_version = file_content[1]
                local parsed_content = active_record_version .. "\n" .. "  def change\n"
                parsed_content = parsed_content .. "    change_column_default :" .. selected_table .. ", :" .. column_name .. ', "new_type"' .. "\n"
                parsed_content = parsed_content .. "  end\n" .. "end\n"

                Path:new(file_created):write(parsed_content, "w")

                if nvim_notify_ok then
                  nvim_notify.dismiss()
                  nvim_notify(
                    parsed_data,
                    vim.log.levels.INFO,
                    { title = "Migration generated successfully!", timeout = 5000 }
                  )
                  vim.api.nvim_command("edit " .. file_created)
                else
                  vim.notify("Migration generated successfully!")
                  vim.api.nvim_command("edit " .. file_created)
                end
              end,
              on_stderr = function(_, error)
                if error[1] ~= "" then
                  print("Error: ")
                  print(vim.inspect(error))
                end
              end
            })
            close_floating_window()
          else
            close_floating_window()
          end
        end
      )
    else
      close_floating_window()
    end
  end)
end

return M
