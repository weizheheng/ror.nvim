local ror = {}

function ror.setup(opts)
  opts = opts or {}

  require("ror.config").set_defaults(opts)
end

return ror
