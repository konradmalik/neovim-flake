return {
    ---generates a func to asyncronously ask for selection when launching dap.
    ---Ex. select dll to debug
    ---@param title string title. eg. "Path to dll"
    ---@param command string[] command to run to list all options. Eg. { "fd", "--hidden", "--no-ignore", "--type", "f", "--full-path", "bin/Debug/.+\\.dll" }
    ---@return thread pass this to 'program' in dap config
    telescope_select = function(title, command)
        local finders = require("telescope.finders")
        local pickers = require("telescope.pickers")
        local conf = require("telescope.config").values
        local action_state = require("telescope.actions.state")
        local actions = require("telescope.actions")

        return coroutine.create(function(coro)
            local opts = {}
            pickers
                .new(opts, {
                    prompt_title = title,
                    finder = finders.new_oneshot_job(command, {}),
                    sorter = conf.generic_sorter(opts),
                    attach_mappings = function(buffer_number)
                        actions.select_default:replace(function()
                            actions.close(buffer_number)
                            coroutine.resume(coro, action_state.get_selected_entry()[1])
                        end)
                        return true
                    end,
                })
                :find()
        end)
    end,
}
