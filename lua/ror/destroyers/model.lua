local M = {}

function M.destroy()
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
    {
      prompt = "Select model to be destroyed:"
    },
    function (model_name)
      if model_name ~= nil then
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

        if nvim_notify_ok then
          nvim_notify(
            "Command: bin/rails destroy model " .. model_name .. "...",
            "warn",
            { title = "Destroying model...", timeout = false }
          )
        else
          vim.notify("Destroying model...")
        end

        vim.fn.jobstart({ "bin/rails", "destroy", "model", model_name }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if not data then
              return
            end

            local parsed_data = {}
            for i, v in ipairs(data) do
              -- Removing white space
              parsed_data[i] = string.gsub(v, '^%s*(.-)%s*$', '%1')
            end

            if nvim_notify_ok then
              nvim_notify.dismiss()
              nvim_notify(
                parsed_data,
                vim.log.levels.ERROR,
                { title = "Model destroyed successfully!", timeout = 5000 }
              )
            else
              vim.notify("Model destroyed successfully!")
            end
          end,
          on_stderr = function(_, error)
            if error[1] ~= "" then
              print("Error: ")
              print(vim.inspect(error))
            end
          end
        })
      end
    end
  )
end

return M
