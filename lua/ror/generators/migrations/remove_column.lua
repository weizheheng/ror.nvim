local M = {}

M.REMOVE_COLUMN_RESULT = { model_name = "", columns = {} }

local function reset(close_floating_window)
  close_floating_window()
  M.REMOVE_COLUMN_RESULT = { model_name = "", columns = {} }
end

local function remove_column_steps(close_floating_window, columns)
  vim.ui.select({"Yes", "No"}, { prompt = "Remove more column?" }, function(choice2)
    if choice2 == "Yes" then
      local filtered_columns = {}
      for _, column in ipairs(columns) do
        local found = false
        for _, selected_table in ipairs(M.REMOVE_COLUMN_RESULT.columns) do
            if column == selected_table then
                found = true
                break
            end
        end

        if not found then
          table.insert(filtered_columns, column)
        end
      end

      vim.ui.select(
        filtered_columns,
        { prompt = "Which column to remove?" },
        function (selected_column)
          if selected_column ~= nil then
            table.insert(M.REMOVE_COLUMN_RESULT.columns, selected_column)
            remove_column_steps(close_floating_window, filtered_columns)
          else
            reset(close_floating_window)
          end
        end
      )
    elseif choice2 == "No" then
      local remove_column_result = M.REMOVE_COLUMN_RESULT

      local command = { "bin/rails", "generate", "migration",  }

      local remove_column_string = "remove"
      for _, column in ipairs(remove_column_result.columns) do
        -- info = name:string
        local start, _ = string.find(column, ":")
        local to_be_deleted_column = string.sub(column, 1, start - 1)
        print(to_be_deleted_column)
        remove_column_string = remove_column_string .. "_" .. to_be_deleted_column
      end
      remove_column_string = remove_column_string .. "_from_" .. remove_column_result.model_name
      table.insert(command, remove_column_string)

      for _, column in ipairs(remove_column_result.columns) do
        table.insert(command, column)
      end

      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

      if nvim_notify_ok then
        nvim_notify(
          "Command: bin/rails generate migration " .. remove_column_string .. "...",
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
            parsed_data[i] = string.gsub(v, '^%s*(.-)%s*$', '%1')
          end

          local file_created = string.gsub(parsed_data[2], "create    ", "")
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
      reset(close_floating_window)
    else
      reset(close_floating_window)
    end
  end)
end

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

  vim.ui.select(parsed_table_names, { prompt = "Removing column(s) from which table?" }, function(table_name)
    if table_name ~= nil then
      M.REMOVE_COLUMN_RESULT.model_name = table_name

      local awk_command = string.format('/create_table "%s"/{flag=1;next}/end$/{flag=0}flag', table_name)
      local columns = vim.split(vim.fn.system({ "awk", awk_command, root_path .. "/db/schema.rb" }), "\n")
      local parsed_columns = {}
      for _, column in pairs(columns) do
        if column ~= "" and not string.match(column, "t.index") then
          local column_type = string.match(column, "t%.(%w+)")
          local column_name = string.match(column, 't%.%w+%s+"([^"]+)')

          table.insert(parsed_columns, column_name .. ":" .. column_type)
        end
      end

      vim.ui.select(
        parsed_columns,
        { prompt = "Which column to remove?" },
        function (selected_column)
          if selected_column ~= nil then
              table.insert(M.REMOVE_COLUMN_RESULT.columns, selected_column)
            remove_column_steps(close_floating_window, parsed_columns)
          else
            reset(close_floating_window)
          end
        end
      )
    else
      reset(close_floating_window)
    end
  end)
end

return M
