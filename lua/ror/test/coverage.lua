local Path = require("plenary.path")

local M = {}

function M.percentage(original_file_path)
  local root_path = vim.fn.getcwd()
  local json_coverage_file_path = root_path .. "/coverage/coverage.json"

  if vim.fn.glob(json_coverage_file_path) == '' then
    return nil
  end

  local coverage_table = vim.fn.json_decode(Path:new(json_coverage_file_path):read())

  local current_file_coverage
  -- Default JSON Formatter
  if coverage_table.coverage then
    for key, value in pairs(coverage_table.coverage) do
      if key == original_file_path then
        current_file_coverage = value.lines
      end
    end
  -- Custom simplecov-json formatter
  elseif coverage_table.files then
    for _, value in pairs(coverage_table.files) do
      if value.filename == original_file_path then
        print(vim.inspect(value))
        current_file_coverage = value.coverage.lines
      end
    end
  else
    return nil
  end

  if current_file_coverage == nil then
    return nil
  end

  local function filter_not_nil_coverage(table)
    local result = {}

    for _, value in ipairs(table) do
      if value ~= vim.NIL then
        result[#result + 1] = value
      end
    end

    return result
  end

  local filtered_coverage = filter_not_nil_coverage(current_file_coverage)

  local function get_covered_lines_count(table)
    local count = 0
    for _, value in ipairs(table) do
      if value ~= 0 then
        count = count + 1
      end
    end

    return count
  end

  local coverage_percentage = get_covered_lines_count(filtered_coverage) / #filtered_coverage * 100

  return coverage_percentage
end

return M
