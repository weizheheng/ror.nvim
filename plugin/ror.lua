vim.api.nvim_create_user_command("RorMinitestRun", function(attributes)
  require("ror.minitest").run(attributes.args)
end, {
  nargs = "?",
  complete = function()
    -- return completion candidates as a list-like table
    return { "Line" }
  end,
})

vim.api.nvim_create_user_command("RorMinitestClear", function()
  require("ror.minitest").clear()
end, {})

vim.api.nvim_create_user_command("RorMinitestAttachTerminal", function()
  require("ror.minitest").attach_terminal()
end, {})

