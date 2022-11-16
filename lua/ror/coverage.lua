local Path = require("plenary.path")
local config = require("ror.config").values.test

local M = {}

function M.show()
  local up_hl_group = config.coverage.up
  local down_hl_group = config.coverage.down

  if up_hl_group ~= "DiffAdd" then
    if vim.fn.hlexists("RorCoverageUp") == 0 then
      vim.api.nvim_command("hi RorCoverageUp " .. config.coverage.up)
    end

    up_hl_group = "RorCoverageUp"
  end
  if down_hl_group ~= "DiffDelete" then
    if vim.fn.hlexists("RorCoverageDown") == 0 then
      vim.api.nvim_command("hi RorCoverageDown " .. config.coverage.down)
    end

    down_hl_group = "RorCoverageDown"
  end

  local root_path = vim.fn.getcwd()
  if vim.fn.glob(root_path .. "/coverage/coverage.json") == '' then
    return
  end

  local json_coverage_file_path = root_path .. "/coverage/coverage.json"
  local coverage = vim.fn.json_decode(Path:new(json_coverage_file_path):read())

  local original_file_path = root_path .. "/" .. vim.fn.expand('%')
  local ns = vim.api.nvim_create_namespace("ror-coverage")
  local bufnr = vim.api.nvim_get_current_buf()

  local function get_current_file_coverage(table)
    -- Default JSON Formatter
    if table.coverage then
      for key, value in pairs(table.coverage) do
        if key == original_file_path then
          return value.lines
        end
      end
    -- Custom simplecov-json formatter
    elseif table.files then
      for _, value in pairs(table.files) do
        if value.filename == original_file_path then
          return value.coverage.lines
        end
      end
    else
      return nil
    end
  end

  local current_file_coverage_table = get_current_file_coverage(coverage)

  if current_file_coverage_table == nil then
    return
  end

  for index, value in pairs(current_file_coverage_table) do
    if value == 0 then
      vim.api.nvim_buf_add_highlight(bufnr, ns, down_hl_group, index - 1, 0, -1)
    elseif value ~= vim.NIL then
      vim.api.nvim_buf_add_highlight(bufnr, ns, up_hl_group, index - 1, 0, -1)
    end
  end
end

function M.clear()
  local ns = vim.api.nvim_create_namespace("ror-coverage")
  local bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return M
