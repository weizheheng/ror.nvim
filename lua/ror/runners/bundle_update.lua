local Path = require("plenary.path")

local M = {}

function M.run()
  local root_path = vim.fn.getcwd()
  local gemfile = vim.fn.split(Path:new(root_path .. "/Gemfile"):read(), "\n")
  local parsed_gems = { "All" }

  for _, gem in pairs(gemfile) do
    if string.match(gem, "^gem") then
      local parsed_gem = string.match(gem, 'gem%s+"([^"]+)')
      table.insert(parsed_gems, parsed_gem)
    end
  end

  vim.ui.select(
    parsed_gems,
    { prompt = "Which gem to update?" },
    function (selected_gem)
      if selected_gem ~= nil then
        local update_command = { "bundle", "update" }
        local command_text = "Command: bundle update"
        if selected_gem ~= "All" then
          table.insert(update_command, selected_gem)
          command_text = command_text .. " " .. selected_gem
        end
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

        if nvim_notify_ok then
          nvim_notify(
            command_text,
            "warn",
            { title = "Running bundle update...", timeout = false }
          )
        else
          vim.notify("Running bundle update...")
        end

        vim.fn.jobstart(update_command, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if not data then
              return
            end

            if nvim_notify_ok then
              nvim_notify.dismiss()
              nvim_notify(
                command_text,
                vim.log.levels.INFO,
                { title = "bundle update ran successfully!", timeout = 5000 }
              )
            else
              vim.notify("bundle update ran successfully!")
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
