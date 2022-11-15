local config = require("ror.config").values.test

local M = {}

function M.notify(message, opts)
  local opts = opts or {}

  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok and config.notification_style == 'nvim-notify' then
    nvim_notify(message, opts.kind or "warn", { title = opts.title or "Tests" })
  else
    vim.notify(message)
  end
end

return M
