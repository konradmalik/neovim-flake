-- https://github.com/ansible/ansible-language-server

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.ansiblels(), "--stdio" },
}
