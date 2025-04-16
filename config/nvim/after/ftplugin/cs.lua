require("pde.printf-debug").set_keymap(
    function(name) return "Console.WriteLine(" .. name .. ");" end,
    function(var) return "Console.WriteLine(JsonSerializer.Serialize(" .. var .. "));" end
)
