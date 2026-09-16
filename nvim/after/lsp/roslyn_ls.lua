---@param command lsp.Command
---@return boolean
local function validate_command(command)
    if #command.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(command.arguments), vim.log.levels.ERROR)
        return false
    end

    return true
end

---@param path string
---@param needle string
---@return boolean
local function file_contains(path, needle)
    local ok, lines = pcall(vim.fn.readfile, path)
    return ok and table.concat(lines, "\n"):find(needle, 1, true) ~= nil
end

---@type table<string, boolean>
local mtp_cache = {}

---Tells if the solution runs on Microsoft.Testing.Platform instead of VSTest.
---@param root_dir string
---@return boolean
local function uses_mtp(root_dir)
    if mtp_cache[root_dir] == nil then
        mtp_cache[root_dir] = file_contains(
            vim.fs.joinpath(root_dir, "global.json"),
            '"runner": "Microsoft.Testing.Platform"'
        ) or file_contains(
            vim.fs.joinpath(root_dir, "Directory.Build.props"),
            "<TestingPlatformDotnetTestSupport>true"
        )
    end
    return mtp_cache[root_dir]
end

---@param cwd string
---@param filter string
local function testRun(cwd, filter)
    -- build separately with errors only, otherwise build warnings spam the test output
    local build = "dotnet build --verbosity quiet --clp:ErrorsOnly"
    local test = "dotnet test --no-build --verbosity quiet"
    if uses_mtp(cwd) then
        test = test .. (' -- --ignore-exit-code 8 --filter "%s"'):format(filter)
    else
        test = test
            .. (' --nologo --logger "console;verbosity=detailed" --filter "%s"'):format(filter)
    end

    require("pde.runner").run(build .. " && " .. test, { cwd = cwd })
end

---@param bufnr integer?
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
        -- avoid fullSolution because it's slow for large codebases
        ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
        },
    },
    commands = {
        ["roslyn.client.peekReferences"] = function() vim.lsp.buf.references() end,
        ["dotnet.test.run"] = function(command, ctx)
            if not validate_command(command) then return end

            local bufnr = ctx.bufnr
            ensure_tree_is_parsed(bufnr)

            ---@diagnostic disable-next-line: undefined-field
            local range = command.arguments[1].range
            local root_node = assert(get_node_at_range(bufnr, range))
            local root_name = vim.treesitter.get_node_text(root_node, bufnr)

            local filters = { root_name }
            ---@param node TSNode
            local function insert_filter(node)
                local name_node = node:field("name")[1]
                if not name_node:equal(root_node) then
                    table.insert(filters, 1, vim.treesitter.get_node_text(name_node, bufnr))
                end
            end

            ---@type TSNode?
            local curr_node = root_node
            -- gather all classes and namespaces along the way to the top
            while curr_node and curr_node:type() ~= "compilation_unit" do
                if
                    curr_node:type() == "class_declaration"
                    or curr_node:type() == "namespace_declaration"
                then
                    insert_filter(curr_node)
                end

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

            local filter = table.concat(filters, ".")
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            testRun(client.root_dir, filter)
        end,
    },
}
