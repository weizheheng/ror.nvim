local M = {}

function M.list_commands()
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
    {
      "Generate model", "Generate controller", "Generate migration", "Generate mailer", "Generate system test",
      "Find models", "Find controllers", "Find views", "Find model tests", "Find controller tests", "Find system tests", "Find migrations",
      "Test current file", "Test current line", "Clear test result", "Attach test terminal",
      "Show file coverage", "Hide file coverage",
      "Go to model", "Go to controller", "Go to test", "Go to view", "Vertical split model", "Vertical split controller", "Vertical split test",
      "List routes", "Sync routes", "Sync routes without path helper",
      "List table columns",
      "Destroy model", "Destroy controller", "Destroy migration",
    },
    { prompt = "Select your ROR helper commands" },
    function (command)
      if command == "Generate model" then
        require("ror.generators.model").generate(close_floating_window)
      elseif command == "Generate controller" then
        require("ror.generators.controller").generate(close_floating_window)
      elseif command == "Generate migration" then
        require("ror.generators.migration").generate(close_floating_window)
      elseif command == "Generate mailer" then
        require("ror.generators.mailer").generate(close_floating_window)
      elseif command == "Generate system test" then
        require("ror.generators.system_test").generate(close_floating_window)
      elseif command == "Find models" then
        close_floating_window()
        require("ror.finders.model").find()
      elseif command == "Find controllers" then
        close_floating_window()
        require("ror.finders.controller").find()
      elseif command == "Find views" then
        close_floating_window()
        require("ror.finders.view").find()
      elseif command == "Find model tests" then
        close_floating_window()
        require("ror.finders.model_test").find()
      elseif command == "Find controller tests" then
        close_floating_window()
        require("ror.finders.controller_test").find()
      elseif command == "Find system tests" then
        close_floating_window()
        require("ror.finders.system_test").find()
      elseif command == "Find migrations" then
        close_floating_window()
        require("ror.finders.migration").find()
      elseif command == "Test current file" then
        close_floating_window()
        require("ror.test").run()
      elseif command == "Test current line" then
        close_floating_window()
        require("ror.test").run("Line")
      elseif command == "Clear test result" then
        close_floating_window()
        require("ror.test").clear()
      elseif command == "Attach test terminal" then
        close_floating_window()
        require("ror.test").attach_terminal()
      elseif command == "Show file coverage" then
        close_floating_window()
        require("ror.coverage").show()
      elseif command == "Hide file coverage" then
        close_floating_window()
        require("ror.coverage").clear()
      elseif command == "Go to model" then
        close_floating_window()
        require("ror.navigations").go_to_model("normal")
      elseif command == "Go to controller" then
        close_floating_window()
        require("ror.navigations").go_to_controller("normal")
      elseif command == "Go to test" then
        close_floating_window()
        require("ror.navigations").go_to_test("normal")
      elseif command == "Go to view" then
        close_floating_window()
        require("ror.navigations").go_to_view()
      elseif command == "Vertical split model" then
        close_floating_window()
        require("ror.navigations").go_to_model("vsplit")
      elseif command == "Vertical split controller" then
        close_floating_window()
        require("ror.navigations").go_to_controller("vsplit")
      elseif command == "Vertical split test" then
        close_floating_window()
        require("ror.navigations").go_to_test("vsplit")
      elseif command == "List routes" then
        require("ror.routes").list_routes()
      elseif command == "Sync routes" then
        close_floating_window()
        require("ror.routes").sync_routes()
      elseif command == "Sync routes without path helper" then
        close_floating_window()
        require("ror.routes").sync_routes_without_path_helper()
      elseif command == "List table columns" then
        close_floating_window()
        require("ror.schema").list_table_columns()
      elseif command == "Destroy model" then
        require("ror.destroyers.model").destroy()
      elseif command == "Destroy controller" then
        require("ror.destroyers.controller").destroy()
      elseif command == "Destroy migration" then
        require("ror.destroyers.migration").destroy()
      else
        close_floating_window()
      end
    end
  )
end

return M
