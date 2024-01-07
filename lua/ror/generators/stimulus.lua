local M = {}

function M.generate(close_floating_window)
  vim.ui.input(
    { prompt = "Generates a new Stimulus controller" },
    function (controller)
      if controller ~= nil then
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

        if nvim_notify_ok then
          nvim_notify(
            "Command: bin/rails generate stimulus " .. controller  .. "...",
            "warn",
            { title = "Generating system stimulus controller...", timeout = false }
          )
        else
          vim.notify("Generating system stimulus controller...")
        end

        vim.fn.jobstart({ "bin/rails", "generate", "stimulus", controller }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if not data then
              return
            end

            local parsed_data = {}
            for i, v in ipairs(data) do
              parsed_data[i] = string.gsub(v, '^%s*(.-)%s*$', '%1')
            end
            local file_created = string.gsub(parsed_data[1], "create ", "")

            if nvim_notify_ok then
              nvim_notify.dismiss()
              nvim_notify(
                parsed_data,
                vim.log.levels.INFO,
                { title = "Stimulus controller generated successfully!", timeout = 5000 }
              )
              vim.api.nvim_command("edit " .. file_created)
            else
              vim.notify("Stimulus controller generated successfully!")
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
end

return M
