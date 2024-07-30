local binaries = require("pde.binaries")
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
        "console;verbosity=detailed",
        "--verbosity",
        "quiet",
        "--clp:ErrorsOnly",
        "--filter",
        filter,
    }
    runner.run(cmd, { cwd = cwd })
end

---@param root_node TSNode
---@return TSNode?
local function get_class_name_node(root_node)
    ---@type TSNode?
    local class_node = root_node
    while class_node and class_node:type() ~= "class_declaration" do
        class_node = class_node:parent()
    end

    if class_node then return class_node:field("name")[1] end
end

---@param root_node TSNode
---@return TSNode?
local function get_namespace_name_node(root_node)
    ---@type TSNode?
    local ns_node = root_node
    while
        ns_node
        and ns_node:type() ~= "namespace_declaration"
        and ns_node:type() ~= "file_scoped_namespace_declaration"
    do
        ns_node = ns_node:parent()
    end

    if ns_node then return ns_node:field("name")[1] end
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

local function get_config()
    return {
        settings = {
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
                local root_node = get_node_at_range(bufnr, range)
                if not root_node then
                    vim.notify(
                        "cannot find root node " .. vim.inspect(range["start"]),
                        vim.log.levels.ERROR
                    )
                    return
                end

                local root_name = vim.treesitter.get_node_text(root_node, bufnr)
                local class_name_node = get_class_name_node(root_node)
                if class_name_node and class_name_node:id() ~= root_node:id() then
                    local class_name = vim.treesitter.get_node_text(class_name_node, bufnr)
                    root_name = class_name .. "." .. root_name
                end

                local ns_name_node = get_namespace_name_node(class_name_node or root_node)
                if ns_name_node then
                    local ns_name = vim.treesitter.get_node_text(ns_name_node, bufnr)
                    root_name = ns_name .. "." .. root_name
                end

                local client = vim.lsp.get_client_by_id(ctx.client_id)
                assert(client)

                testRun(client.root_dir, root_name)
            end,
        },
    }
end

local M = {}

function M.get_roslyn_config()
    return {
        exe = binaries.roslyn_ls(),
        config = get_config(),
    }
end

return M
