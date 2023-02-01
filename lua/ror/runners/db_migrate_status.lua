local M = {}

function M.run()
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
  if nvim_notify_ok then
    nvim_notify(
      "Command: bin/rails db:migrate:status",
      "warn",
      { title = "Running db:migrate:status...", timeout = false }
    )
  else
    vim.notify("Running db:migrate:status...")
  end

  vim.fn.jobstart({ "bin/rails", "db:migrate:status" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end

      local parsed_data = {}

      for i, v in ipairs(data) do
        if i == 3 then
          parsed_data[i] = "(Last 10 migrations)"
        -- Headers info 5 rows
        -- Empty rows 2 at the end of line
        -- 5 + 10 + 2
        elseif i > 6 and #data < 17 then
          parsed_data[i] = v
        elseif i > 6 and #data > 17 then
          break
        else
          parsed_data[i] = v
        end
      end

      if #data > 17 then
        -- Has two empty line
        local last_line_index = #data - 2
        for j=1, 10, 1 do
          parsed_data[5 + j] = data[last_line_index - 10 + j]
        end
      end

      if nvim_notify_ok then
        nvim_notify.dismiss()
        nvim_notify(
          parsed_data,
          vim.log.levels.INFO,
          {
            title = "db:migrate:status ran successfully!",
            timeout = 10000,
          }
        )
      else
        vim.notify("db:migrate:status ran successfully!")
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
