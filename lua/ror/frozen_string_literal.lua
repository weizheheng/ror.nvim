local M = {}

function M.add()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "# frozen_string_literal: true" })
  vim.api.nvim_buf_set_lines(bufnr, 1, 1, false, { "" })
end

return M
