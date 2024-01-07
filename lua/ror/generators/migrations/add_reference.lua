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

  vim.ui.select(parsed_table_names, { prompt = "Adding reference to which table?" }, function(selected_table)
    if selected_table ~= nil then
      local model_migrations = vim.split(vim.fn.system({ "find", "db/migrate", "-name", "*_create_*" }), "\n")
      local parsed_model_names = {}

      for _, migration in pairs(model_migrations) do
        if migration ~= "" then
          local filename = vim.fn.fnamemodify(migration, ":t:r")
          local _, finish = string.find(filename, "_create_")
          local plural_model_names = string.sub(filename, finish + 1, #filename)
          local parsed_model_name

          if plural_model_names:sub(-3) == "ies" then
            parsed_model_name = plural_model_names:sub(1, -4) .. "y"
          elseif plural_model_names:sub(-2) == "es" then
            parsed_model_name = plural_model_names:sub(1, -3) .. ""
          elseif plural_model_names:sub(-1) == "s" then
            parsed_model_name = plural_model_names:sub(1, -2) .. ""
          end

          table.insert(parsed_model_names, parsed_model_name)
        end
      end

      vim.ui.select(
        parsed_model_names,
        { prompt = "Referencing which model?" },
        function (selected_model)
          if selected_model ~= nil then
            local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

            local migration_name = "add_" .. selected_model .. "_to_" .. selected_table
            local references = selected_model .. ":references"
            local command = { "bin/rails", "generate", "migration", migration_name, references }
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
