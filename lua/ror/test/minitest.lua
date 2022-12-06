local config = require("ror.config").values.test
local coverage = require("ror.test.coverage")
local notify_instance = require("ror.test.notify")

local M = {}

local function get_coverage_percentage(test_path)
  local root_path = vim.fn.getcwd()
  local original_file_path = string.gsub(test_path, "test", "/app", 1)
  original_file_path = root_path .. string.gsub(original_file_path, "_test", "")

  local _, finish = string.find(original_file_path, ".rb")

  if finish ~= nil then
    original_file_path = string.sub(original_file_path, 1, finish)
  end

  return coverage.percentage(original_file_path)
end

function M.run(test_path, bufnr, ns, terminal_bufnr, notify_record, type)
  local cmd

  if type == "Last" then
    cmd = vim.g.ror_last_command
  else
    cmd = { "rails", "test", test_path, "--json" }
  end

  vim.fn.termopen(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local failed = {}
      local function filter_response(response)
        for _, v in ipairs(response) do
          if string.find(v, '{"examples":') then
            return v
          end
        end
      end

      local filtered_result = filter_response(data)

      if not filtered_result then
        return
      end

      local function get_start_index(result)
        local start, _ = string.find(result, '{"examples":')

        return start
      end

      local function get_finish_index(result)
        local _, finish = string.find(result, "}}")

        return finish
      end

      local start_index = get_start_index(filtered_result)
      local finish_index = get_finish_index(filtered_result)
      local result = vim.json.decode(string.sub(filtered_result, start_index, finish_index))

      M.statistics = result.statistics

      for _, line in ipairs(result.examples) do
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
      local coverage_ok, coverage_percentage = pcall(get_coverage_percentage, test_path)

      -- Set the statistics window
      local message = "Assertions: " .. M.statistics.assertions .. ", Failures: " .. M.statistics.failures

      if coverage_ok and coverage_percentage ~= nil then
        local formatted_coverage = string.format("%.2f%%", coverage_percentage)
        message = message .. ", Coverage: " .. formatted_coverage
      end

      local kind

      if M.statistics.failures and M.statistics.failures > 0 then
        kind = vim.log.levels.ERROR
      else
        kind = vim.log.levels.INFO
      end

      notify_instance.notify(
        message,
        kind,
        notify_record,
        {
          bufnr = bufnr,
          title = "Result: " .. vim.fn.fnamemodify(test_path, ":t")
        }
      )

      -- delete the terminal buffer
      vim.api.nvim_buf_delete(terminal_bufnr, {})
    end,
  })
end

return M
