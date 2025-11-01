local M = {}

function M.destroy()
  local root_path = vim.fn.getcwd()
  local migrations = vim.split(vim.fn.glob(root_path .. "/db/migrate/*rb"), "\n")
  local parsed_migrations = {}

  for _, value in ipairs(migrations) do
    -- take only the filename without extension
    local filename = vim.fn.fnamemodify(value, ":t:r")
    local start, _ = string.find(filename, "_")
    local parsed_filename = string.sub(filename, start + 1)
    table.insert(parsed_migrations, 1, parsed_filename)
  end

  vim.ui.select(
    parsed_migrations,
    {
      prompt = "Select migration to be destroyed:"
    },
    function (migration_name)
      if migration_name ~= nil then
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

        if nvim_notify_ok then
          nvim_notify(
            "Command: bin/rails destroy migration " .. migration_name .. "...",
            "warn",
            { title = "Destroying migration...", timeout = false }
          )
        else
          vim.notify("Destroying migration...")
        end

        vim.fn.jobstart({ "bin/rails", "destroy", "migration", migration_name }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if not data then
              return
            end

            local parsed_data = {}
            local file_removed

            for i, v in ipairs(data) do
              parsed_data[i] = string.gsub(v, '%s+', ' ') -- Replace one or more whitespace characters with a single space
              parsed_data[i] = string.gsub(parsed_data[i], '^%s*(.-)%s*$', '%1')
              -- Check if the parsed data contains the phrase
              if parsed_data[i]:find("remove db/migrate") then
                file_removed = string.gsub(parsed_data[i], "remove ", "")
              end
            end

            if nvim_notify_ok then
              nvim_notify.dismiss()
              nvim_notify(
                "File: " .. file_removed,
                vim.log.levels.INFO,
                { title = "Migration destroyed successfully!", timeout = 5000 }
              )
            else
              vim.notify("Migration destroyed successfully!")
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
