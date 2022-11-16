local config = require("ror.config").values.test

local M = {}

M.instances = {}

function M.notify(message, kind, notify_record, opts)
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok then
    opts.timeout = config.notification.timeout

    if not M.instances[opts.bufnr] then
      M.instances[opts.bufnr] = nvim_notify.instance({})
    end

    if config.notification.timeout == false and notify_record ~= nil then
      opts.replace = notify_record
    end

    return M.instances[opts.bufnr](message, kind, opts)
  else
    local prefix
    if kind == "warn" then
      prefix = "Running Test "
    else
      prefix = "Result: "
    end
    return vim.notify(prefix .. message)
  end
end

function M.dismiss(bufnr)
  if M.instances[bufnr] then
    M.instances[bufnr].dismiss()
  end
end

return M
