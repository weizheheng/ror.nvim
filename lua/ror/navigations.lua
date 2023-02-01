local M = {}

function M.go_to_model(mode)
  require("ror.navigators.model").visit(mode)
end

function M.go_to_controller(mode)
  require("ror.navigators.controller").visit(mode)
end

function M.go_to_test(mode)
  require("ror.navigators.test").visit(mode)
end

function M.go_to_view()
  require("ror.navigators.view").visit()
end

return M
