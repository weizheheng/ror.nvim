local config = require("ror.config").values.test
local notify_instance = require("ror.test.notify")

local M = {}

local function non_empty_last_line(bufnr)
  local lines = vim.fn.getbufline(bufnr, 1, '$')

  local line = ""

  for i = #lines, 1, -1 do
    if lines[i] ~= "" then
      line = lines[i]

      break
    end
  end

  return line
end

local function verify_debugger()
  if M.terminal_bufnr and vim.fn.bufexists(M.terminal_bufnr) then
    local last_line = non_empty_last_line(M.terminal_bufnr)

    if last_line == '[Process exited 1]' or vim.fn.bufnr() == M.terminal_bufnr then
      return
    elseif last_line:match('%(byebug%)') or last_line:match('pry%(#.*%)') or last_line:match('%(rdbg%)') or last_line == ':' then
      M.attach_terminal()
      vim.cmd("startinsert")
    else
      vim.fn.timer_start(500, function ()
        verify_debugger()
      end)
    end
  end
end

local function run(type)
  local bufnr
  local ns
  local relative_file_path
  local cursor_position

  if vim.g.ror_last_command and type == "Last" then
    bufnr = vim.g.ror_last_bufnr
    relative_file_path = vim.g.ror_last_relative_file_path
    cursor_position = vim.g.ror_last_cursor_position
  elseif type == "Last" then
    vim.notify("No tests to be runned")
  else
    bufnr = vim.api.nvim_get_current_buf()
    relative_file_path = vim.fn.expand("%:~:.")
    cursor_position = vim.api.nvim_win_get_cursor(0)[1]

    vim.g.ror_last_bufnr = bufnr
    vim.g.ror_last_relative_file_path = relative_file_path
    vim.g.ror_last_cursor_position = cursor_position
  end

  local ns = vim.api.nvim_create_namespace("ror-minitest")

  local function get_test_path()
    if type == "Line" then
      return relative_file_path .. ":" .. cursor_position
    else
      return relative_file_path
    end
  end
  local test_path = get_test_path()

  -- Clear extmark
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  -- Reset current diagnostic
  vim.diagnostic.reset(ns, bufnr)
  -- Close notification window
  notify_instance.dismiss(bufnr)

  local function get_notification_message()
    local path = vim.fn.fnamemodify(relative_file_path, ":t")

    if type == "Line" then
      return "File: " .. path .. ":" .. cursor_position
    elseif type == "OnlyFailures" then
      return "File: " .. path .. ": only failures"
    elseif type == "Last" then
      return "Rerunning last command at: " .. path
    else
      return "File: " .. path
    end
  end

  local function get_notification_title()
    if type == "Line" then
      return config.message.line
    else
      return config.message.file
    end
  end

  local notification_message = get_notification_message()
  local notification_title = get_notification_title()

  local notify_record = notify_instance.notify(
    notification_message,
    "warn",
    nil,
    { bufnr = bufnr, title = notification_title }
  )

  local terminal_bufnr = vim.api.nvim_create_buf(false, true)

  M.terminal_bufnr = terminal_bufnr

  vim.fn.timer_start(500, function ()
    verify_debugger()
  end)


  vim.api.nvim_buf_call(terminal_bufnr, function()
    if string.find(test_path, "_spec.rb") then
      require("ror.test.rspec").run(test_path, bufnr, ns, terminal_bufnr, notify_record, type)
    else
      require("ror.test.minitest").run(test_path, bufnr, ns, terminal_bufnr, notify_record, type)
    end
  end)
end

local function clear()
  local bufnr = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("ror-minitest")
  -- Clear extmark
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  -- Hide current diagnostic
  vim.diagnostic.hide(ns, bufnr)
  -- Close notification window
  notify_instance.dismiss(bufnr)
end

function M.run(type)
  run(type)
end

function M.clear()
  clear()
end

function M.attach_terminal()
  if M.terminal_bufnr ~= nil and vim.fn.buffer_exists(M.terminal_bufnr) ~= 0 then
    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor((ui.width * 0.5) + 0.5)
    local height = math.floor((ui.height * 0.5) + 0.5)

    local term_buf_info = vim.fn.getbufinfo(M.terminal_bufnr)[1]

    local window_config = {
      relative = "editor",
      anchor = "SW",
      width = width,
      height = height,
      col = (ui.width - width) / 2,
      row = (ui.height - height),
      style = 'minimal',
      border = "double"
    }

    if term_buf_info.hidden == 1 then
      vim.api.nvim_open_win(
        M.terminal_bufnr,
        true,
        window_config
      )
    else
      vim.api.nvim_win_close(0, true)
    end
  else
    print("No active terminal buffer to attach to.")
  end
end

return M
