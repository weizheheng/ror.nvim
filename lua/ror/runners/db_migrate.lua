local M = {}

function M.run()
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
  if nvim_notify_ok then
    nvim_notify(
      "Command: bin/rails db:migrate",
      "warn",
      { title = "Running db:migrate...", timeout = false }
    )
  else
    vim.notify("Running db:migrate...")
  end

  local migrated = false

  vim.fn.jobstart({ "bin/rails", "db:migrate" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end

      local parsed_data = {}
      for i, v in ipairs(data) do
        if v ~= "" then
          if string.match(v, "migrated") then
            migrated = true
          end
          parsed_data[i] = string.gsub(v, '^%s*(.-)%s*$', '%1')
        end
      end

      if migrated then
        if nvim_notify_ok then
          nvim_notify.dismiss()
          nvim_notify(
            parsed_data,
            vim.log.levels.INFO,
            {
              title = "db:migrate ran successfully!",
              timeout = 5000,
            }
          )
        else
          vim.notify("db:migrate ran successfully!")
        end
      end
    end,
    on_stderr = function(_, error)
      if not migrated then
        if nvim_notify_ok and not migrated then
          nvim_notify.dismiss()
          nvim_notify(
            "Something went wrong running db:migrate",
            vim.log.levels.ERROR,
            {
              title = "Error running db:migrate!",
              timeout = 5000,
            }
          )
        else
          vim.notify("Error running db:migrate!")
        end
      end
    end
  })
end

return M
