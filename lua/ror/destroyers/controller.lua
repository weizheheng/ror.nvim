local M = {}

function M.destroy()
  local root_path = vim.fn.getcwd()
  local controllers = vim.split(vim.fn.glob(root_path .. "/app/controllers/**/*rb"), "\n")
  local parsed_controllers = {}
  for _, value in ipairs(controllers) do
    -- take only the filename without extension
    local filename = vim.fn.fnamemodify(value, ":~:r")
    local _, finish = string.find(filename, "controllers/")
    local parsed_filename = string.sub(filename, finish + 1)
    table.insert(parsed_controllers, parsed_filename)
  end

  vim.ui.select(
    parsed_controllers,
    {
      prompt = "Select controller to be destroyed:"
    },
    function (controller_name)
      if controller_name ~= nil then
        vim.ui.input(
          { prompt = "Actions to remove from routes (separated by space)" },
          function (actions)
            if actions ~= nil then
              local destroy_command = { "bin/rails", "destroy", "controller", controller_name }
              for action in actions:gmatch("%w+") do table.insert(destroy_command, action) end

              local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

              if nvim_notify_ok then
                nvim_notify(
                  "Command: bin/rails destroy controller " .. controller_name .. "...",
                  "warn",
                  { title = "Destroying controller...", timeout = false }
                )
              else
                vim.notify("Destroying controller...")
              end

              vim.fn.jobstart(destroy_command, {
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
                      { title = "Controller destroyed successfully!", timeout = 5000 }
                    )
                  else
                    vim.notify("Controller destroyed successfully!")
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
    end
  )
end

return M
