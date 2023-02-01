local M = {}

function M.select_commands()
  vim.ui.select(
    { "db:migrate", "db:rollback STEP=1", "bundle install", "bundle update", "db:migrate:status" },
    {
      prompt = "Select your runner!"
    },
    function (choice)
      if choice == "db:migrate" then
        require("ror.runners.db_migrate").run()
      elseif choice == "db:rollback STEP=1" then
        require("ror.runners.db_rollback").run()
      elseif choice == "bundle install" then
        require("ror.runners.bundle_install").run()
      elseif choice == "bundle update" then
        require("ror.runners.bundle_update").run()
      elseif choice == "db:migrate:status" then
        require("ror.runners.db_migrate_status").run()
      end
    end
  )
end

return M
