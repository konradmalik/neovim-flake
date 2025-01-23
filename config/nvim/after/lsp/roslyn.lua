local runner = require("pde.runner")

---@param command lsp.Command
---@return boolean
local function validate_command(command)
    if #command.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(command.arguments), vim.log.levels.ERROR)
        return false
    end

    return true
end

local function testRun(cwd, filter)
    local cmd = {
        "dotnet",
        "test",
        "--nologo",
        "--logger",
        '"console;verbosity=detailed"',
        "--verbosity",
        "quiet",
        "--clp:ErrorsOnly",
        "--filter",
        '"' .. filter .. '"',
    }
    runner.run(cmd, { cwd = cwd })
end

---@param bufnr any
---@param range table<string, table<string,integer>>
---@return TSNode|nil
local function get_node_at_range(bufnr, range)
    return vim.treesitter.get_node({
        bufnr = bufnr,
        pos = { range["start"].line, range["start"].character },
    })
end

---@param bufnr integer
local function ensure_tree_is_parsed(bufnr)
    if not vim.treesitter.highlighter.active[bufnr] then
        vim.treesitter.get_parser(bufnr):parse()
    end
end

---@type vim.lsp.Config
return {
    settings = {
        ["csharp|completion"] = {
            dotnet_provide_regex_completions = false,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
        },
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },
    },
    commands = {
        ["roslyn.client.peekReferences"] = function() vim.lsp.buf.references() end,
        ["dotnet.test.run"] = function(command, ctx)
            if not validate_command(command) then return end

            local bufnr = ctx.bufnr
            local range = command.arguments[1].range

            ensure_tree_is_parsed(bufnr)
            local root_node = assert(get_node_at_range(bufnr, range))
            local root_name = vim.treesitter.get_node_text(root_node, bufnr)

            local filters = { root_name }
            ---@param node TSNode
            local function insert_filter(node)
                local name_node = node:field("name")[1]
                if not name_node:equal(root_node) then
                    table.insert(filters, 1, vim.treesitter.get_node_text(name_node, bufnr))
                end
                return node:field("name")[1]
            end

            ---@type TSNode?
            local curr_node = root_node
            -- gather all classes and namespaces along the way to the top
            while curr_node and curr_node:type() ~= "compilation_unit" do
                if curr_node:type() == "class_declaration" then insert_filter(curr_node) end
                if curr_node:type() == "namespace_declaration" then insert_filter(curr_node) end

                curr_node = curr_node:parent()
            end

            -- once we're on the top, check if we have file_scoped_namespace_declaration
            if curr_node then
                for node, _ in curr_node:iter_children() do
                    if node:type() == "file_scoped_namespace_declaration" then
                        insert_filter(node)
                        break
                    end
                end
            end

            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            local filter = table.concat(filters, ".")
            testRun(client.root_dir, filter)
        end,
    },
}
