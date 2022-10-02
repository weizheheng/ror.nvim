local config = require("ror.config").values.test

local M = {}

function M.run(test_path, bufnr, ns, notification_winnr, notification_bufnr, terminal_bufnr)
  vim.fn.termopen({ "rails", "test", test_path, "--json" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local failed = {}
      local function filter_response(response)
        local new_table = {}
        local index = 1
        for _, v in ipairs(response) do
          if string.find(v, '{"name":') then
            new_table[index] = v
            index = index + 1
          end
        end

        return new_table
      end

      local filtered_result = filter_response(data)

      if not filtered_result then
        return
      end

      for _, line in ipairs(filtered_result) do
        local decoded = vim.json.decode(line)
        if decoded.status == "PASS" then
          local text = { config.pass_icon }
          vim.api.nvim_buf_set_extmark(bufnr, ns, tonumber(decoded.line) - 1, 0, {
            virt_text = { text }
          })
        else
          local text = { config.fail_icon }
          vim.api.nvim_buf_set_extmark(bufnr, ns, tonumber(decoded.line) - 1, 0, {
            virt_text = { text }
          })
          table.insert(failed, {
            bufnr = bufnr,
            lnum = tonumber(decoded.line) - 1,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            source = "minitest",
            message = decoded.failures,
            user_data = {},
          })
        end
      end

      vim.diagnostic.set(ns, bufnr, failed, {})
    end,
    on_stderr = function(_, data)
      if data[1] ~= "" then
        print("Error DATA: ")
        print(vim.inspect(data))
      end
    end,
    on_exit = function()
      -- close the notification window
      vim.api.nvim_win_close(tonumber(notification_winnr), true)
      -- delete the notification buffer
      vim.api.nvim_buf_delete(notification_bufnr, {})
      -- delete the terminal buffer
      vim.api.nvim_buf_delete(terminal_bufnr, {})
    end,
  })
end

return M
