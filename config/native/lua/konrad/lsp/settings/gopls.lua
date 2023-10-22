-- https://github.com/golang/tools/tree/master/gopls

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.gopls() },
    -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    settings = {
        gopls = {
            allExperiments = true,
        },
    },
}
