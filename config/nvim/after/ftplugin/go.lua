require("pde.printf-debug").set_keymap(
    function(name) return "fmt.Println(" .. name .. ")" end,
    function(var) return 'fmt.Printf("%v\n", ' .. var .. ")" end
)

-- vim.keymap.set("v", "<leader>cl", function()
--     vim.fn.feedkeys(
--         get_logging_keys(
--             function(name) return "print(" .. name .. ")" end,
--             function(var) return "print(" .. var .. ")" end
--         )
--     )
-- end)
--
-- vim.keymap.set("v", "<leader>cl", function()
--     vim.fn.feedkeys(
--         get_logging_keys(
--             function(name) return "echo " .. name end,
--             function(var) return 'echo "$' .. var .. '"' end
--         )
--     )
-- end)
