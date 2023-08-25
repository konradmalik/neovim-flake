local reloader = require("plenary.reload").reload_module

P = function(v)
    print(vim.inspect(v))
    return v
end

RELOAD = function(...)
    return reloader(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end
