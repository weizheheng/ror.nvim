local Path = require("plenary.path")

local M = {}

local function get_ror_path()
  return vim.fn.getenv("HOME") .. "/.cache/ror/"
end

local function get_project_path()
  local repo_table = vim.fn.split(vim.fn.system("git rev-parse --show-toplevel"), "/")
  local parsed_repo_name = vim.fn.split(repo_table[#repo_table], "\n")[1]
  return get_ror_path() .. parsed_repo_name
end

local function get_routes_path()
  return get_project_path() .. "/routes.json"
end

local function create_ror_directory()
  local ror_path = get_ror_path()
  -- Create a initial default path
  if vim.fn.glob(ror_path) == '' then
    vim.fn.mkdir(ror_path, "p")
  end
end

local function create_project_directory()
  local project_path = get_project_path()
  if vim.fn.glob(project_path) == '' then
    vim.fn.mkdir(project_path, "p")
  end
end

function M.sync_routes()
  create_ror_directory()
  create_project_directory()
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok then
    nvim_notify(
      "Command: bin/rails routes",
      "warn",
      { title = "Syncing routes...", timeout = false }
    )
  else
    vim.notify("Syncing routes...")
  end

  vim.fn.jobstart({ "bin/rails", "routes" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local parsed_routes = {}
      for index, route in ipairs(data) do
        if index ~= 1 and route ~= "" and not string.match(route, "rails") and not string.match(route, "turbo") and not string.match(route, "/assets") then
          local parsed_route = string.gsub(route, "^%s+", "")
          parsed_route = string.gsub(parsed_route, "%s+$", "")
          parsed_route = string.gsub(parsed_route, "%s+", " ")
          table.insert(parsed_routes, parsed_route)
        end
      end
      local routes_path = get_routes_path()
      Path:new(routes_path):write(vim.fn.json_encode(parsed_routes), "w")

      if nvim_notify_ok then
        nvim_notify.dismiss()
        nvim_notify(
          "File path: " .. routes_path,
          vim.log.levels.INFO,
          { title = "Rails routes synced successfully!", timeout = 5000 }
        )
      else
        vim.notify("Rails routes synced successfully!")
      end
    end,
    on_error = function(_, error)
      print(error)
    end
  })
end

function M.sync_routes_without_path_helper()
  create_ror_directory()
  create_project_directory()
  local nvim_notify_ok, nvim_notify = pcall(require, 'notify')

  if nvim_notify_ok then
    nvim_notify(
      "Command: bin/rails routes",
      "warn",
      { title = "Syncing routes...", timeout = false }
    )
  else
    vim.notify("Syncing routes...")
  end

  vim.fn.jobstart({ "bin/rails", "routes" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local parsed_routes = {}
      for index, route in ipairs(data) do
        if index ~= 1 and route ~= "" and not string.match(route, "rails") and not string.match(route, "turbo") and not string.match(route, "/assets") then
          local parsed_route = string.gsub(route, "^%s+", "")
          parsed_route = string.gsub(parsed_route, "%s+$", "")
          parsed_route = string.gsub(parsed_route, "%s+", " ")
          local start, _ = string.find(parsed_route, "[A-Z]")
          local route_without_path_helper = string.sub(parsed_route, start)
          table.insert(parsed_routes, route_without_path_helper)
        end
      end
      local routes_path = get_routes_path()
      Path:new(routes_path):write(vim.fn.json_encode(parsed_routes), "w")

      if nvim_notify_ok then
        nvim_notify.dismiss()
        nvim_notify(
          "File path: " .. routes_path,
          vim.log.levels.INFO,
          { title = "Rails routes synced successfully!", timeout = 5000 }
        )
      else
        vim.notify("Rails routes synced successfully!")
      end
    end,
    on_error = function(_, error)
      print(error)
    end
  })
end

function M.list_routes()
  local routes = vim.json.decode(Path:new(get_routes_path()):read())
  vim.ui.select(
    routes,
    { prompt = "Available routes" },
    function (route)
      if route ~= nil then
        local nvim_notify_ok, nvim_notify = pcall(require, 'notify')
        if nvim_notify_ok then
          nvim_notify.dismiss()
          nvim_notify(
            route,
            vim.log.levels.INFO,
            { title = "Selected Route", timeout = 8000 }
          )
        else
          vim.notify(route)
        end
      end
    end
  )
end

return M
