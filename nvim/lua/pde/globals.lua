local function reload(...) return require("plenary.reload").reload_module(...) end

P = function(v)
    vim.notify(vim.inspect(v), vim.log.levels.DEBUG)
    return v
end

R = function(name)
    reload(name)
    return require(name)
end
