# vim: ft=lua
{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/settings/jsonls.lua" ''
  -- https://github.com/hrsh7th/vscode-langservers-extracted
  local schemastore_ok, schemastore = pcall(require, "schemastore")
  if not schemastore_ok then
      vim.notify("cannot load schemastore")
      return
  end

  return {
      cmd = { "${pkgs.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver", "--stdio" },
      init_options = {
          provideFormatter = false, -- use prettier from null-ls instead
      },
      settings = {
          json = {
              format = false,
              validate = true,
              schemas = schemastore.json.schemas(),
          },
      },
  }
''
