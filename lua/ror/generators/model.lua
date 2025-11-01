local M = {}

M.MODEL_GENERATOR_RESULT = { model_name = "", columns = {} }

local function reset(close_floating_window)
  close_floating_window()
  M.MODEL_GENERATOR_RESULT = { model_name = "", columns = {} }
end

local function model_generator_steps(close_floating_window)
  local result = {}

  vim.ui.select({"Yes", "No"}, { prompt = "Add new column?" }, function(choice2)
    if choice2 == "Yes" then
      vim.ui.input(
        { prompt = "STEP 1: Enter new column name" },
        function (input)
          if input ~= nil then
            result.column_name = input
            vim.ui.select(
              { "primary_key", "integer", "bigint", "float", "decimal", "boolean", "rich_text", "binary", "string", "text", "date", "time", "datetime", "digest", "token", "references" },
              { prompt = "STEP 2: Select a column type" },
              function (column_type)
                result.column_type = column_type

                if column_type == "token" then
                  table.insert(M.MODEL_GENERATOR_RESULT.columns, result)
                  model_generator_steps(close_floating_window)
                elseif column_type ~= nil then
                  vim.ui.select(
                    { "No index", "Normal index", "Uniq index" },
                    { prompt = "STEP 3: Add index to column?" },
                    function (index_type)
                      if index_type ~= nil then
                        result.index_type = index_type
                        table.insert(M.MODEL_GENERATOR_RESULT.columns, result)
                        model_generator_steps(close_floating_window)
                      else
                        reset(close_floating_window)
                      end
                    end
                  )
                else
                  reset(close_floating_window)
                end
              end
            )
          else
            reset(close_floating_window)
          end
        end
      )
  elseif choice2 == "No" then
      local command = M.MODEL_GENERATOR_RESULT

      local generate_command = { "bin/rails", "generate", "model", command.model_name }

      for _, info in ipairs(command.columns) do
        local column_name = info.column_name
        local column_type = info.column_type
        local uniq_type = info.index_type

        local column_info = column_name .. ":" .. column_type
        if uniq_type == "Normal index" then
          column_info = column_info .. ":" .. "index"
        elseif  uniq_type == "Uniq index" then
          column_info = column_info .. ":" .. "uniq"
        end

        table.insert(generate_command, column_info)
      end

      local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

      if nvim_notify_ok then
        nvim_notify(
          "Command: bin/rails generate model " .. command.model_name .. "...",
          "warn",
          { title = "Generating model...", timeout = false }
        )
      else
        vim.notify("Generating model...")
      end

      vim.fn.jobstart(generate_command, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if #data == 1 and data[1] == "" then
            return
          end

          local parsed_data = {}
          local model_file_created
          local migration_file_created

          for i, v in ipairs(data) do
            parsed_data[i] = string.gsub(v, '%s+', ' ') -- Replace one or more whitespace characters with a single space
            parsed_data[i] = string.gsub(parsed_data[i], '^%s*(.-)%s*$', '%1')
            -- Check if the parsed data contains the phrase "create app/controllers"
            if parsed_data[i]:find("create app/models") then
              model_file_created = string.gsub(parsed_data[i], "create ", "")
            end

            if parsed_data[i]:find("create db/migrate") then
              migration_file_created = string.gsub(parsed_data[i], "create ", "")
            end
          end

          if nvim_notify_ok then
            nvim_notify.dismiss()
            nvim_notify(
              { "File: ", "- " .. model_file_created, "- " .. migration_file_created },
              vim.log.levels.INFO,
              { title = "Model generated successfully!", timeout = 5000 }
            )
            vim.api.nvim_command("edit " .. model_file_created)
            vim.api.nvim_command("vsplit " .. migration_file_created)
          else
            vim.notify("Model generated successfully!")
            vim.api.nvim_command("edit " .. model_file_created)
            vim.api.nvim_command("vsplit " .. migration_file_created)
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

function M.generate(close_floating_window)
  vim.ui.input(
    { prompt = "New model name: " },
    function (input)
      if input ~= nil then
        M.MODEL_GENERATOR_RESULT.model_name = input
        model_generator_steps(close_floating_window)
      else
        reset(close_floating_window)
      end
    end
  )
end

return M
