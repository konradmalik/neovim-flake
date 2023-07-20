-- caching needs to be first
require("konrad.loader")

-- this should contain plugins that I need to control the execution order of
-- or the ones that are simply hard dependencies of the rest in ./plugins
require("konrad.keymaps") -- maps leader
require("konrad.globals")
require("konrad.options")
require("konrad.colorscheme")
require("konrad.signs")

require("konrad.gitsigns")
require("konrad.heirline")
require("konrad.cmp")
require("konrad.dap")
