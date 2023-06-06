# vim: ft=lua
{ pkgs }:
pkgs.writeTextDir "lua/konrad/dap/configurations/cs.lua" ''
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
      vim.notify("cannot load dap")
      return
  end

  dap.adapters.coreclr = {
      type = 'executable',
      command = '${pkgs.netcoredbg}/bin/netcoredbg',
      args = { '--interpreter=vscode' }
  }

  dap.configurations.cs = {
      {
          type = "coreclr",
          name = "Launch netcoredbg",
          request = "launch",
          program = coroutine.create(function(dap_run_co)
              local dlls = vim.fn.glob('./**/Debug/*/*.dll', true, true)
              vim.ui.select(dlls, {
                  prompt = 'Select dll to debug:',
                  format_item = function(item)
                      return "debugee > " .. item
                  end,
              }, function(choice)
                  coroutine.resume(dap_run_co, choice)
              end)
          end),
      },
      {
          type = "coreclr",
          name = "Launch netcoredbg (with args)",
          request = "launch",
          program = coroutine.create(function(dap_run_co)
              local dlls = vim.fn.glob('./**/Debug/*/*.dll', true, true)
              vim.ui.select(dlls, {
                  prompt = 'Select dll to debug:',
                  format_item = function(item)
                      return "debugee > " .. item
                  end,
              }, function(choice)
                  coroutine.resume(dap_run_co, choice)
              end)
          end),
          args = coroutine.create(function(dap_run_co)
              vim.ui.input({
                  prompt = 'Args:',
              }, function(input)
                  coroutine.resume(dap_run_co, input)
              end)
          end),
      },
  }
''
