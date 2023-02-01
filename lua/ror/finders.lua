local M = {}


function M.select_finders()
  vim.ui.select(
    { "Models", "Controllers", "Migrations", "Views", "Model tests", "Controller tests", "System tests" },
    { prompt = "What are you looking for?" },
    function (finder)
      if finder == "Models" then
        require("ror.finders.model").find()
      elseif finder == "Controllers" then
        require("ror.finders.controller").find()
      elseif finder == "Migrations" then
        require("ror.finders.migration").find()
      elseif finder == "Views" then
        require("ror.finders.view").find()
      elseif finder == "Model tests" then
        require("ror.finders.model_test").find()
      elseif finder == "Controller tests" then
        require("ror.finders.controller_test").find()
      elseif finder == "System tests" then
        require("ror.finders.system_test").find()
      end
    end
  )
end

return M
