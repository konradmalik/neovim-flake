---@type CapabilityHandler
return {
    name = "Navic",
    attach = function(data)
        local bufnr = data.bufnr
        local client = data.client

        vim.cmd.packadd("nvim-navic")
        require("nvim-navic").attach(client, bufnr)

        return {}
    end,
}
