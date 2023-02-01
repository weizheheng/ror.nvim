local M = {}

function M.run()
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok then
    nvim_notify(
      "Command: bundle install",
      "warn",
      { title = "Running bundle install...", timeout = false }
    )
  else
    vim.notify("Running bundle install...")
  end

  vim.fn.jobstart({ "bundle", "install" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end

      if nvim_notify_ok then
        nvim_notify.dismiss()
        nvim_notify(
          "Command: bundle install",
          vim.log.levels.INFO,
          { title = "bundle install ran successfully!", timeout = 5000 }
        )
      else
        vim.notify("bundle install ran successfully!")
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

return M
