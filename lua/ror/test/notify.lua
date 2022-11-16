local M = {}

M.instances = {}

function M.notify(message, kind, opts)
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok then
    opts.timeout = false

    if not M.instances[opts.bufnr] then
      M.instances[opts.bufnr] = nvim_notify.instance({})
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
