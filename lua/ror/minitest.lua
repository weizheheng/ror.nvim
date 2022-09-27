local config = require("ror.config").values.minitest

local M = {}

local function run(type)
  local bufnr = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("ror-minitest")
  local relative_file_path = vim.fn.expand('%')
  local cursor_position = vim.api.nvim_win_get_cursor(0)[1]

  local function get_test_path()
    if type == "Line" then
      return relative_file_path .. ":" .. cursor_position
    else
      return relative_file_path
    end
  end

  -- Clear extmark
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  -- Reset current diagnostic
  vim.diagnostic.reset(ns, bufnr)

  local notification_bufnr = vim.api.nvim_create_buf(false, true)
  -- Create a test running floating window
  local function get_notification_message()
    if type == "Line" then
      return config.message.line .. " " .. cursor_position .. "..."
    else
      return config.message.file
    end
  end
  local notification_winnr = vim.api.nvim_open_win(
    notification_bufnr,
    false,
    { relative="cursor", anchor="SW", width=#get_notification_message(), height=1, row=0, col=0, border="double", style="minimal" }
  )
  vim.api.nvim_buf_set_lines(notification_bufnr, 0, -1, false, { get_notification_message() })

  vim.fn.jobstart({ "rails", "test", get_test_path(), "--json" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local failed = {}

      if not data then
        return
      end

      -- Remove the first line Running 3 tests in a single process (parallelization threshold is 50)
      table.remove(data, 1)

      -- Remove the last element which is an empty ""
      table.remove(data)

      for _, line in ipairs(data) do
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
    end,
  })
end

local function clear()
  local bufnr = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("ror-minitest")
  -- Clear extmark
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  -- Hide current diagnostic
  vim.diagnostic.hide(ns, bufnr)
end

function M.run(type)
  run(type)
end

function M.clear()
  clear()
end

return M
