vim.api.nvim_create_user_command("RorTestRun", function(attributes)
  require("ror.test").run(attributes.args)
end, {
  nargs = "?",
  complete = function()
    -- return completion candidates as a list-like table
    return { "Line" }
  end,
})

vim.api.nvim_create_user_command("RorTestClear", function()
  require("ror.test").clear()
end, {})

vim.api.nvim_create_user_command("RorTestAttachTerminal", function()
  require("ror.test").attach_terminal()
end, {})

vim.api.nvim_create_user_command("RorShowCoverage", function()
  require("ror.coverage").show()
end, {})

vim.api.nvim_create_user_command("RorClearCoverage", function()
  require("ror.coverage").clear()
end, {})

vim.api.nvim_create_user_command("RorAddFrozenStringLiteral", function()
  require("ror.frozen_string_literal").add()
end, {})

vim.api.nvim_create_user_command("RorGenerators", function()
  require("ror.generators").select_generators()
end, {})

vim.api.nvim_create_user_command("RorDestroyers", function()
  require("ror.destroyers").select_destroyers()
end, {})

vim.api.nvim_create_user_command("RorCliCommands", function()
  require("ror.cli").select_commands()
end, {})

vim.api.nvim_create_user_command("RorSchemaListColumns", function()
  require("ror.schema").list_table_columns()
end, {})

vim.api.nvim_create_user_command("RorListRoutes", function()
  require("ror.routes").list_routes()
end, {})

vim.api.nvim_create_user_command("RorCommands", function()
  require("ror.commands").list_commands()
end, {})

vim.api.nvim_create_user_command("RorFinders", function()
  require("ror.finders").list_finders()
end, {})
