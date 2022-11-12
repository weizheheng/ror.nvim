local config = require("ror.config").values.test
local coverage = require("ror.test.coverage")

local M = {}

local function get_coverage_percentage(test_path)
  local root_path = vim.fn.getcwd()
  local original_file_path = string.gsub(test_path, "spec", "/app", 1)
  original_file_path = root_path .. string.gsub(original_file_path, "_spec", "")

  local _, finish = string.find(original_file_path, ".rb")

  if finish ~= nil then
    original_file_path = string.sub(original_file_path, 1, finish)
  end

  return coverage.percentage(original_file_path)
end

function M.run(test_path, bufnr, ns, notification_winnr, notification_bufnr, terminal_bufnr)
  vim.fn.termopen({ "bundle", "exec", "rspec", test_path, "--format", "j" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local failed = {}

      if not data then
        return
      end

      local function filter_result(response_data)
        if #response_data == 1 then
          -- Without hitting the debugger/pry
          return vim.json.decode(response_data[1])
        else
          local function filter_response(response)
            for _, v in ipairs(response) do
              if string.find(v, '{"version"') then
                return v
              elseif string.find(v, "{\"version\"") then
                return v
              end
            end
          end

          local filtered_result = filter_response(response_data)

          local function get_start_index(result)
            local start, _ = string.find(result, '{"version"')
            if start == nil then
              start, _ = string.find(result, '{"version"')
            end

            return start
          end

          local function get_finish_index(result)
            local _, finish = string.find(result, 'failure"}')
            if finish == nil then
              _, finish = string.find(result, 'failures"}')
            end

            return finish
          end

          local start_index = get_start_index(filtered_result)
          local finish_index = get_finish_index(filtered_result)

          return vim.json.decode(string.sub(filtered_result, start_index, finish_index))
        end
      end

      local result = filter_result(data)
      M.summary = result.summary

      for _, decoded in ipairs(result.examples) do
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
      local coverage_percentage = get_coverage_percentage(test_path)

      -- Set the statistics window
      local message = "Examples: " .. M.summary.example_count .. ", Failures: " .. M.summary.failure_count

      if coverage_percentage ~= nil then
        local formatted_coverage = string.format("%.2f%%", coverage_percentage)
        message = message .. ", Coverage: " .. formatted_coverage
      end
      vim.api.nvim_win_set_width(notification_winnr, #message)
      vim.api.nvim_buf_set_lines(notification_bufnr, 0, -1, false, { message })
      -- delete the terminal buffer
      vim.api.nvim_buf_delete(terminal_bufnr, {})
    end,
  })
end

return M
