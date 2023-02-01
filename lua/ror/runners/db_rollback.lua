local M = {}

function M.run()
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok then
    nvim_notify(
      "Command: bin/rails db:rollback STEP=1",
      "warn",
      { title = "Running db:rollback STEP=1...", timeout = false }
    )
  else
    vim.notify("Running db:rollback STPE=1...")
  end

vim.fn.jobstart({ "bin/rails", "db:rollback", "STEP=1" }, {
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
        { title = "db:rollback STEP=1 ran successfully!", timeout = 5000 }
      )
    else
      vim.notify("db:rollback STEP=1 ran successfully!")
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
