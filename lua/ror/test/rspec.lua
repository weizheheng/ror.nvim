local config = require("ror.config").values.test

local M = {}

function M.run(test_path, bufnr, ns, notification_winnr, notification_bufnr, terminal_bufnr)
  vim.fn.termopen({ "bundle", "exec", "rspec", test_path, "--format", "j" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local failed = {}

      if not data then
        return
      end

      local function get_examples(response_data)
        if #response_data == 1 then
          -- Without hitting the debugger/pry
          return vim.json.decode(response_data[1]).examples
        else
          local function filter_response(response)
            for _, v in ipairs(response) do
              if string.find(v, '{"version"') then
                return v
              end
            end
          end

          local filtered_result = filter_response(response_data)
          local start, _ = string.find(filtered_result, '{"version"')
          local _, finish = string.find(filtered_result, 'failures"}')

          return vim.json.decode(string.sub(filtered_result, start, finish)).examples
        end
      end


      for _, decoded in ipairs(get_examples(data)) do
        if decoded.status == "passed" then
          local text = { config.pass_icon }
          vim.api.nvim_buf_set_extmark(bufnr, ns, tonumber(decoded.line_number) - 1, 0, {
            virt_text = { text }
          })
        else
          local function filter_backtrace(backtrace)
            local new_table = {}
            local index = 1
            for _, v in ipairs(backtrace) do
              if string.find(v, '_spec.rb:') then
                new_table[index] = v
                break
              end
            end

            return new_table
          end

          local fail_backtrace = filter_backtrace(decoded.exception.backtrace)[1]
          local example_line = string.match(fail_backtrace, ":([^:]+)")

          local text = { config.fail_icon }
          vim.api.nvim_buf_set_extmark(bufnr, ns, tonumber(example_line) - 1, 0, {
            virt_text = { text }
          })
          table.insert(failed, {
            bufnr = bufnr,
            lnum = tonumber(example_line) - 1,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            source = "rspec",
            message = decoded.exception.message,
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
