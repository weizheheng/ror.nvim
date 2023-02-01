local M = {}

M.ADD_COLUMN_RESULT = { model_name = "", columns = {} }

local function reset(close_floating_window)
  close_floating_window()
  M.ADD_COLUMN_RESULT = { model_name = "", columns = {} }
end

local function add_column_steps(close_floating_window)
  local result = {}

  vim.ui.select({"Yes", "No"}, { prompt = "Add new column?" }, function(choice2)
    if choice2 == "Yes" then
      vim.ui.input(
        { prompt = "Enter new column name: " },
        function (input)
          if input ~= nil then
            result.column_name = input
            vim.ui.select(
              { "primary_key", "decimal", "integer", "float", "boolean", "bigint", "binary", "string", "text", "date", "time", "datetime" },
              { prompt = "STEP 2: Select a column type" },
              function (column_type)
                result.column_type = column_type

                table.insert(M.ADD_COLUMN_RESULT.columns, result)
                add_column_steps(close_floating_window)
              end
            )
          else
            reset(close_floating_window)
          end
        end
      )
  elseif choice2 == "No" then
      local add_columns_info = M.ADD_COLUMN_RESULT

      local command = { "bin/rails", "generate", "migration",  }

      local add_column_string = "add"
      for _, info in ipairs(add_columns_info.columns) do
        add_column_string = add_column_string .. "_" .. info.column_name
      end
      add_column_string = add_column_string .. "_to_" .. add_columns_info.model_name
      table.insert(command, add_column_string)

      for _, info in ipairs(add_columns_info.columns) do
        local column_name = info.column_name
        local column_type = info.column_type

        local column_info = column_name .. ":" .. column_type

        table.insert(command, column_info)
      end

      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

      if nvim_notify_ok then
        nvim_notify(
          "Command: bin/rails generate migration " .. add_column_string .. "...",
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

          if nvim_notify_ok then
            nvim_notify.dismiss()
            nvim_notify(
              parsed_data,
              vim.log.levels.INFO,
              { title = "Migration generated successfully!", timeout = 5000 }
            )
          else
            vim.notify("Migration generated successfully!")
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

  vim.ui.select(parsed_table_names, { prompt = "Adding column(s) to which model?" }, function(selected_model)
    if selected_model ~= nil then
      M.ADD_COLUMN_RESULT.model_name = selected_model
      add_column_steps(close_floating_window)
    else
      reset(close_floating_window)
    end
  end)
end

return M
