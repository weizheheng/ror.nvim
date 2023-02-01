local M = {}

function M.generate(close_floating_window)
  vim.ui.input(
    { prompt = "Give your system test a meaningful name" },
    function (test_name)
      if test_name ~= nil then
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

        if nvim_notify_ok then
          nvim_notify(
            "Command: bin/rails generate system_test " .. test_name  .. "...",
            "warn",
            { title = "Generating system test...", timeout = false }
          )
        else
          vim.notify("Generating system test...")
        end

        vim.fn.jobstart({ "bin/rails", "generate", "system_test", test_name }, {
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
                { title = "System test generated successfully!", timeout = 5000 }
              )
            else
              vim.notify("System test generated successfully!")
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
end

return M
