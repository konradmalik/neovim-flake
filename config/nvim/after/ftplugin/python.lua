require("pde.printf-debug").set_keymap(
    function(name) return "print(" .. name .. ")" end,
    function(var) return "print(" .. var .. ")" end
)
