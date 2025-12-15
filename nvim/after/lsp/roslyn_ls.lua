local runner = require("pde.runner")

local initToken = 0

---@param command lsp.Command
---@return boolean
local function validate_command(command)
    if #command.arguments ~= 1 then
        vim.notify("unexpected arguments: " .. vim.inspect(command.arguments), vim.log.levels.ERROR)
        return false
    end

    return true
end

---@param cwd string
---@param filter string
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

---@class RoslynCodeAction
---@field title string
---@field code_action lsp.CodeAction

---@param nested_code_actions lsp.CodeAction[]
---@return RoslynCodeAction[]
local function get_code_actions(nested_code_actions)
    return vim.iter(nested_code_actions)
        :map(
            ---@param it lsp.CodeAction
            ---@return RoslynCodeAction
            function(it)
                local code_action_path = it.data["CodeActionPath"]
                local fix_all_flavors = it.data["FixAllFlavors"]

                if #code_action_path == 1 then
                    ---@type RoslynCodeAction
                    return {
                        title = code_action_path[1],
                        code_action = it,
                    }
                end

                local title = table.concat(code_action_path, " -> ", 2)
                ---@type RoslynCodeAction
                return {
                    title = fix_all_flavors and string.format("Fix All: %s", title) or title,
                    code_action = it,
                }
            end
        )
        :totable()
end

---@param client vim.lsp.Client
---@param data lsp.Command
local function handle_fix_all_code_action(client, data)
    local flavors = data.arguments[1]["FixAllFlavors"]
    vim.ui.select(flavors, { prompt = "Pick a fix all scope:" }, function(flavor)
        ---@diagnostic disable-next-line: param-type-mismatch
        client:request("codeAction/resolveFixAll", {
            title = data.title,
            data = data.arguments[1],
            scope = flavor,
        }, function(err, response)
            if err then vim.notify(err.message, vim.log.levels.ERROR, { title = "roslyn_ls" }) end
            if response and response.edit then
                vim.lsp.util.apply_workspace_edit(response.edit, client.offset_encoding)
            end
        end)
    end)
end

---@param client_id integer
---@param token integer|string
---@param value LspProgress
local function trigger_lsp_progress(client_id, token, value)
    if value.message then value.message = value.message:gsub("[\r\n]", "") end

    vim.api.nvim_exec_autocmds("LspProgress", {
        data = {
            client_id = client_id,
            params = {
                token = token,
                value = value,
            },
        },
    })
end

local initialization_title = "Initialization"
local restore_title = "Restore"

---@param client vim.lsp.Client
---@param target string
local function on_init_sln(client, target)
    initToken = initToken + 1
    trigger_lsp_progress(
        client.id,
        initToken,
        ---@type lsp.WorkDoneProgressBegin
        {
            title = initialization_title,
            kind = "begin",
            message = target,
        }
    )
    ---@diagnostic disable-next-line: param-type-mismatch
    client:notify("solution/open", {
        solution = vim.uri_from_fname(target),
    })
end

---@param client vim.lsp.Client
---@param project_files string[]
local function on_init_project(client, project_files)
    initToken = initToken + 1
    trigger_lsp_progress(
        client.id,
        initToken,
        ---@type lsp.WorkDoneProgressBegin
        {
            title = initialization_title,
            kind = "begin",
            message = table.concat(project_files, ", "),
        }
    )
    ---@diagnostic disable-next-line: param-type-mismatch
    client:notify("project/open", {
        projects = vim.tbl_map(function(file) return vim.uri_from_fname(file) end, project_files),
    })
end

---@param client vim.lsp.Client
local function refresh_diagnostics(client)
    for buf, _ in pairs(client.attached_buffers) do
        if vim.api.nvim_buf_is_loaded(buf) then
            client:request(
                vim.lsp.protocol.Methods.textDocument_diagnostic,
                { textDocument = vim.lsp.util.make_text_document_params(buf) },
                nil,
                buf
            )
        end
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
    handlers = {
        ["workspace/projectInitializationComplete"] = function(err, _, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            refresh_diagnostics(client)
            local message = err and "Error: " .. err or nil

            trigger_lsp_progress(
                ctx.client_id,
                initToken,
                ---@type lsp.WorkDoneProgressEnd
                {
                    title = initialization_title,
                    kind = "end",
                    message = message,
                }
            )
            return vim.NIL
        end,
        ["workspace/_roslyn_projectNeedsRestore"] = function(err, result, ctx)
            -- FIXME: workaround for roslyn_ls bug (sends here .cs files for some reason)
            -- started around 5.0.0-1.25263.3
            local project_file_paths = vim.tbl_get(result, "projectFilePaths") or {}
            if
                vim.iter(project_file_paths)
                    :any(function(path) return vim.endswith(path, ".cs") end)
            then
                -- remove cs files and check if empty afterwards
                -- we could simply filter it out, but empty list would mean "restore-all"
                -- and it's not what we want since csprojs will come in later requests
                project_file_paths = vim.iter(project_file_paths)
                    :filter(function(path) return not vim.endswith(path, ".cs") end)
                    :totable()
                if vim.tbl_isempty(project_file_paths) then
                    ---@type lsp.ResponseError
                    return { code = 0, message = "" }
                end
            end

            local token = math.random(2000000000)
            trigger_lsp_progress(
                ctx.client_id,
                token( ---@type lsp.WorkDoneProgressBegin
                    {
                        title = restore_title,
                        kind = "begin",
                    }
                )
            )

            if err then
                trigger_lsp_progress(
                    ctx.client_id,
                    token,
                    ---@type lsp.WorkDoneProgressEnd
                    {
                        title = restore_title,
                        kind = "end",
                        message = "Error: " .. err,
                    }
                )
                return
            end

            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            client:request(
                ---@diagnostic disable-next-line: param-type-mismatch
                "workspace/_roslyn_restore",
                { projectFilePaths = project_file_paths },
                function(err2, response)
                    if err2 then
                        trigger_lsp_progress(
                            ctx.client_id,
                            token,
                            ---@type lsp.WorkDoneProgressEnd
                            {
                                title = restore_title,
                                kind = "end",
                                message = "Error: " .. err2.message,
                            }
                        )
                    end
                    if response then
                        for _, v in ipairs(response) do
                            trigger_lsp_progress(
                                ctx.client_id,
                                token,
                                ---@type lsp.WorkDoneProgressReport
                                {
                                    title = restore_title,
                                    kind = "report",
                                    message = v.message,
                                }
                            )
                        end
                        trigger_lsp_progress(
                            ctx.client_id,
                            token,
                            ---@type lsp.WorkDoneProgressEnd
                            {
                                title = restore_title,
                                kind = "end",
                            }
                        )
                    end
                end
            )

            return vim.NIL
        end,
    },
    commands = {
        ["roslyn.client.peekReferences"] = function() vim.lsp.buf.references() end,
        ["roslyn.client.fixAllCodeAction"] = function(data, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            handle_fix_all_code_action(client, data)
        end,
        ["roslyn.client.nestedCodeAction"] = function(data, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            local args = data.arguments[1]
            local code_actions = get_code_actions(args["NestedCodeActions"])
            local titles = vim.iter(code_actions):map(function(it) return it.title end):totable()

            vim.ui.select(titles, { prompt = args["UniqueIdentifier"] }, function(selected)
                local action = vim.iter(code_actions)
                    :find(function(it) return it.title == selected end) --[[@as RoslynCodeAction]]

                if action.code_action.data["FixAllFlavors"] then
                    handle_fix_all_code_action(client, action.code_action.command)
                else
                    client:request("codeAction/resolve", {
                        title = action.code_action.title,
                        data = action.code_action.data,
                    }, function(err, response)
                        if err then
                            vim.notify(err.message, vim.log.levels.ERROR, { title = "roslyn_ls" })
                        end
                        if response and response.edit then
                            vim.lsp.util.apply_workspace_edit(response.edit, client.offset_encoding)
                        end
                    end)
                end
            end)
        end,
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
    on_init = {
        function(client)
            local root_dir = client.config.root_dir

            -- try load first solution we find
            for entry, type in vim.fs.dir(root_dir) do
                if
                    type == "file" and (vim.endswith(entry, ".sln") or vim.endswith(entry, ".slnx"))
                then
                    on_init_sln(client, vim.fs.joinpath(root_dir, entry))
                    return
                end
            end

            -- if no solution is found load project
            for entry, type in vim.fs.dir(root_dir) do
                if type == "file" and vim.endswith(entry, ".csproj") then
                    on_init_project(client, { vim.fs.joinpath(root_dir, entry) })
                end
            end
        end,
    },
}
