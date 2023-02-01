local M = {}

function M.select_generators()
  local initial_win_id = vim.api.nvim_get_current_win()
  local ui = vim.api.nvim_list_uis()[1]
  local half_height = math.floor(ui.height * 0.5)
  local half_width = math.floor(ui.width * 0.5)

  local window_config = {
    relative = "editor",
    width = 1,
    height = 1,
    col = half_width - 25,
    row = half_height - 6,
    style = 'minimal',
    focusable = false,
    border = 'none'
  }

  local buf_id = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(buf_id, true, window_config)

  local function close_floating_window()
    vim.api.nvim_win_close(win_id, true)
    vim.api.nvim_buf_delete(buf_id, {})
    vim.api.nvim_set_current_win(initial_win_id)
  end

  vim.ui.select(
    { "model", "controller", "system test", "migration", "mailer" },
    {
      prompt = "Select from the available generators:"
    },
    function (choice)
      if choice == "model" then
        require("ror.generators.model").generate(close_floating_window)
      elseif choice == "controller" then
        require("ror.generators.controller").generate(close_floating_window)
      elseif choice == "system test" then
        require("ror.generators.system_test").generate(close_floating_window)
      elseif choice == "migration" then
        require("ror.generators.migration").generate(close_floating_window)
      elseif choice == "mailer" then
        require("ror.generators.mailer").generate(close_floating_window)
      else
        vim.api.nvim_win_close(win_id, true)
        vim.api.nvim_buf_delete(buf_id, {})
      end
    end
  )

end

return M
