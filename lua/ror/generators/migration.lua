local M = {}

function M.generate(close_floating_window)
  vim.ui.select(
    { "add_column", "remove_column", "add_index", "add_reference", "remove_reference", "change_column_default" },
    {
      prompt = "Select type of migration to be added:"
    },
    function (migration_type)
      if migration_type == "add_column" then
        require("ror.generators.migrations.add_column").run(close_floating_window)
      elseif migration_type == "remove_column" then
        require("ror.generators.migrations.remove_column").run(close_floating_window)
      elseif migration_type == "add_index" then
        require("ror.generators.migrations.add_index").run(close_floating_window)
      elseif migration_type == "add_reference" then
        require("ror.generators.migrations.add_reference").run(close_floating_window)
      elseif migration_type == "remove_reference" then
        require("ror.generators.migrations.remove_reference").run(close_floating_window)
      elseif migration_type == "change_column_default" then
        require("ror.generators.migrations.change_column_default").run(close_floating_window)
      else
        close_floating_window()
      end
    end
  )
end

return M
