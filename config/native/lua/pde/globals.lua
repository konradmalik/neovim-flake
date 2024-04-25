local function reload(...) return require("plenary.reload").reload_module(...) end

P = function(v)
    print(vim.inspect(v))
    return v
end

R = function(name)
    reload(name)
    return require(name)
end
