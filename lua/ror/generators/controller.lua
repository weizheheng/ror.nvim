local M = {}

function M.generate(close_floating_window)
  vim.ui.input(
    { prompt = "New controller name (example: Users)" },
    function (controller_name)
      if controller_name ~= nil then
        vim.ui.input(
          { prompt = "Controller actions (separated by space)" },
          function (actions)
            local generate_command = { "bin/rails", "generate", "controller", controller_name }
            for action in actions:gmatch("%S+") do table.insert(generate_command, action) end

            local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

            if nvim_notify_ok then
              nvim_notify(
                "Command: bin/rails generate controller " .. controller_name .. "...",
                "warn",
                { title = "Generating controller...", timeout = false }
              )
            else
              vim.notify("Generating controller...")
            end

            vim.fn.jobstart(generate_command, {
              stdout_buffered = true,
              on_stdout = function(_, data)
                if not data then
                  return
                end

                local parsed_data = {}
                local file_created

                for i, v in ipairs(data) do
                  parsed_data[i] = string.gsub(v, '%s+', ' ') -- Replace one or more whitespace characters with a single space
                  parsed_data[i] = string.gsub(parsed_data[i], '^%s*(.-)%s*$', '%1')
                  -- Check if the parsed data contains the phrase "create app/controllers"
                  if parsed_data[i]:find("create app/controllers") then
                    file_created = string.gsub(parsed_data[i], "create ", "")
                  end
                end

                if nvim_notify_ok then
                  nvim_notify.dismiss()
                  nvim_notify(
                    "Controller: " .. file_created,
                    vim.log.levels.INFO,
                    { title = "Controller generated successfully!", timeout = 5000 }
                  )
                  vim.api.nvim_command("edit " .. file_created)
                else
                  vim.notify("Controller generated successfully!")
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
          end
        )
      else
        close_floating_window()
      end
    end
  )
end

return M
