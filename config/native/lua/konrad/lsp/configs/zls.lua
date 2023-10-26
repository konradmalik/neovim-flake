-- https://github.com/zigtools/zls

return {
    config = function()
        local binaries = require("konrad.binaries")
        local configs = require("konrad.lsp.configs")
        return {
            cmd = { binaries.zls() },
            root_dir = configs.root_dir({ "zls.json", ".git" }),
        }
    end,
}
