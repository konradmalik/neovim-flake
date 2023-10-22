-- https://github.com/hashicorp/terraform-ls

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.terraformls(), "serve" },
}
