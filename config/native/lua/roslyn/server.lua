local server_object
local roslyn_pipe_name

local M = {}

---starts roslyn and executes on_start
---@param cmd string[] command with args to start roslyn
---@param on_start fun(pipeName: string)
function M.start_server(cmd, on_start)
    if roslyn_pipe_name then
        on_start(roslyn_pipe_name)
        return
    end

    if not server_object then
        vim.notify("starting new roslyn process", vim.log.levels.INFO)
        server_object = vim.system(cmd, {
            stdout = function(_, data)
                if not data then return end

                local success, json_obj = pcall(vim.json.decode, data)
                if not success then return end

                roslyn_pipe_name = json_obj["pipeName"]
                if not roslyn_pipe_name then return end

                vim.schedule(function() on_start(roslyn_pipe_name) end)
            end,
            stderr_handler = function(_, chunk)
                local log = require("vim.lsp.log")
                if chunk and log.error() then log.error("rpc", "dotnet", "stderr", chunk) end
            end,
            detach = false,
        })
    end
end

function M.stop_server()
    if not server_object then return end

    server_object:kill(9)
    roslyn_pipe_name = nil
    server_object = nil
    vim.schedule(function() vim.notify("stopping roslyn process", vim.log.levels.INFO) end)
end

return M
