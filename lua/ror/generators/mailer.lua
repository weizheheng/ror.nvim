local M = {}

function M.generate(close_floating_window)
  vim.ui.input(
    { prompt = "New mailer name: " },
    function (mailer_name)
      if mailer_name ~= nil then
        vim.ui.input(
          { prompt = "Mailer methods (separated by space)" },
          function (methods)
            local generate_command = { "bin/rails", "generate", "mailer", mailer_name }
            for method in methods:gmatch("%w+") do table.insert(generate_command, method) end

            local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

            if nvim_notify_ok then
              nvim_notify(
                "Command: bin/rails generate mailer " .. mailer_name .. " " .. methods .. "...",
                "warn",
                { title = "Generating mailer...", timeout = false }
              )
            else
              vim.notify("Generating mailer...")
            end

            vim.fn.jobstart(generate_command, {
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
                    { title = "Mailer generated successfully!", timeout = 5000 }
                  )
                else
                  vim.notify("Mailer generated successfully!")
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
