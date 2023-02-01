local M = {}

function M.select_destroyers()
  vim.ui.select(
    { "model", "controller", "migration" },
    {
      prompt = "What are you trying to destroy?"
    },
    function (choice)
      if choice == "model" then
        require("ror.destroyers.model").destroy()
      elseif choice == "controller" then
        require("ror.destroyers.controller").destroy()
      elseif choice == "migration" then
        require("ror.destroyers.migration").destroy()
      end
    end
  )

end

return M
