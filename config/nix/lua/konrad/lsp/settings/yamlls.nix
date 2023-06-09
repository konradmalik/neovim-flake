# vim: ft=lua
{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/settings/yamlls.lua" ''
  -- https://github.com/redhat-developer/yaml-language-server
  local schemastore_ok, schemastore = pcall(require, "schemastore")
  if not schemastore_ok then
      vim.notify("cannot load schemastore")
      return
  end

  return {
      cmd = { "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server", "--stdio" },
      settings = {
          redhat = {
              telemetry = {
                  enabled = false,
              },
          },
          yaml = {
              format = {
                  enable = false -- use prettier from null-ls instead
              },
              completion = true,
              hover = true,
              validate = true,
              schemas = vim.tbl_extend("error",
                  schemastore.yaml.schemas(),
                  {
                      ["kubernetes"] = { "k8s/**/*.yml", "k8s/**/*.yaml" },
                      -- or use:
                      -- # yaml-language-server: $schema=<urlToTheSchema>
                  }),
              schemaStore = {
                  -- we use above
                  enable = false,
                  -- https://github.com/dmitmel/dotfiles/blob/master/nvim/dotfiles/lspconfigs/yaml.lua
                  -- yamlls won't work if we disable schemaStore but don't specify url ¯\_(ツ)_/¯
                  url = "",
              },
          },
      }
  }
''
