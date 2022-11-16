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
