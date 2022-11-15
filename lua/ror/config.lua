_RorConfig = _RorConfig or {}

--- Credit to Telescope code base
--- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/config.lua
local function first_non_null(...)
  local n = select("#", ...)
  for i = 1, n do
    local value = select(i, ...)

    if value ~= nil then
      return value
    end
  end
end

local smarter_depth_2_extend = function(priority, base)
  local result = {}
  for key, val in pairs(base) do
    if type(val) ~= "table" then
      result[key] = first_non_null(priority[key], val)
    else
      result[key] = {}
      for k, v in pairs(val) do
        result[key][k] = first_non_null(priority[k], v)
      end
    end
  end
  for key, val in pairs(priority) do
    if type(val) ~= "table" then
      result[key] = first_non_null(val, result[key])
    else
      result[key] = vim.tbl_extend("keep", val, result[key] or {})
    end
  end
  return result
end

local config = {}

config.values = _RorConfig

local ror_defaults = {
  test = {
    message = {
      file = "Running test file",
      line = "Running single test"
    },
    coverage = {
      up = "DiffAdd",
      down = "DiffDelete",
    },
    pass_icon = "✅",
    fail_icon = "❌",
    notification_style = "nvim-notify",
  }
}

function config.set_defaults(user_defaults)
  user_defaults = vim.F.if_nil(user_defaults, {})
  ror_defaults = ror_defaults

  local function get(name, default_val)
    if name == "test" then
      return smarter_depth_2_extend(
        vim.F.if_nil(user_defaults[name], {}),
        vim.tbl_deep_extend("keep", vim.F.if_nil(config.values[name], {}), vim.F.if_nil(default_val, {}))
      )
    end

    return first_non_null(user_defaults[name], config.values[name], default_val)
  end

  local function set(name, default_val)
    config.values[name] = get(name, default_val)
  end

  for key, info in pairs(ror_defaults) do
    set(key, info)
  end
end

config.set_defaults()

return config
