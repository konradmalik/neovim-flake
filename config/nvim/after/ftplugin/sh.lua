require("pde.printf-debug").set_keymap(
    function(name) return "echo " .. name end,
    function(var) return 'echo "$' .. var .. '"' end
)
