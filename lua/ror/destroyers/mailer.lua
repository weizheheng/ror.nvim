local M = {}

function M.destroy()
  local root_path = vim.fn.getcwd()
  local mailers = vim.split(vim.fn.glob(root_path .. "/app/mailers/*rb"), "\n")
  local parsed_mailers = {}

  for _, value in ipairs(mailers) do
    -- take only the filename without extension
    local filename = vim.fn.fnamemodify(value, ":t:r")
    local parsed_mailer = string.match(filename, "(.-)_.*$")
    print(vim.inspect(parsed_mailer))
    table.insert(parsed_mailers, parsed_mailer)
  end

  vim.ui.select(
    parsed_mailers,
    {
      prompt = "Select mailer to be destroyed:"
    },
    function (mailer_name)
      if mailer_name ~= nil then
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

        if nvim_notify_ok then
          nvim_notify(
            "Command: bin/rails destroy mailer " .. mailer_name .. "...",
            "warn",
            { title = "Destroying mailer...", timeout = false }
          )
        else
          vim.notify("Destroying mailer...")
        end

        vim.fn.jobstart({ "bin/rails", "destroy", "mailer", mailer_name }, {
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
                { title = "Mailer destroyed successfully!", timeout = 5000 }
              )
            else
              vim.notify("Mailer destroyed successfully!")
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
