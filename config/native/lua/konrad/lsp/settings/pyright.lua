-- https://github.com/microsoft/pyright

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.pyright(), "--stdio" },
}
