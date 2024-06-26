local binaries = require("pde.binaries")
local roslyn = require("roslyn.server")
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

local function find(pattern)
    return vim.fs.find(function(name, _) return name:match(pattern) end, {
        upward = true,
        stop = vim.uv.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })[1]
end

local function get_config(pipe_name)
    local solution = find(".sln$")
    if not solution then
        -- most probably decompilation from already running server, so reuse it
        -- luacheck: ignore 512
        for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn" })) do
            return client.config
        end
        error("cannot find solution file, nor reuse existing client", vim.log.levels.ERROR)
    end

    local config = assert(require("roslyn").config({
        pipe_name = pipe_name,
        solution = solution,
    }))

    local root_dir = config.root_dir
    config.commands = {
        ["roslyn.client.peekReferences"] = function() vim.lsp.buf.references() end,
        ["dotnet.test.run"] = function(command, ctx)
            if not validate_command(command) then return end

            local range = command.arguments[1].range
            local bufnr = ctx.bufnr

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

            testRun(root_dir, root_name)
        end,
    }
    return config
end

local M = {}

---initializes roslyn server, handles pipe, attaches lsp client
---@param with_config fun(config: vim.lsp.ClientConfig)
function M.wrap(with_config)
    local cmd = {
        binaries.roslyn_ls(),
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
    }
    roslyn.start_server(cmd, function(pipeName)
        local config = get_config(pipeName)
        config.on_exit = function(_, _, _) roslyn.stop_server() end
        with_config(config)
    end)
end

return M
