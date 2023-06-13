# vim: ft=lua
{ pkgs, lib, colorscheme, palette }:
pkgs.writeTextDir "lua/konrad/colorscheme.lua" (
  ''
    local colorscheme = "${colorscheme}";
    if string.find(colorscheme, "catppuccin") then
        local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
        if not catppuccin_ok then
            vim.notify("cannot load catppuccin")
            return
        end

        catppuccin.setup({
            flavour = vim.split(colorscheme, "-")[2],
            -- required to override default cache which is repo path - fails in nix (/nix/store)
            compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
            integrations = {
                indent_blankline = {
                    enabled = true,
                },
                native_lsp = {
                    enabled = true,
                },
            },
        })

        vim.cmd.colorscheme "catppuccin"
        return
    else
        local colorscheme_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
        if colorscheme_ok then
            return
        else
            vim.notify("cannot load colorscheme " .. colorscheme)
        end
    end
  ''
    + lib.optionalString (palette != null)
    ''
      vim.cmd('packadd mini.base16')
      local mini_base16_ok, mini_base16 = pcall(require, "mini.base16")
      if not mini_base16_ok then
          vim.notify("cannot load mini.base16")
          return
      end

      mini_base16.setup({
          palette = {
              base00 = "#${palette.base00}",
              base01 = "#${palette.base01}",
              base02 = "#${palette.base02}",
              base03 = "#${palette.base03}",
              base04 = "#${palette.base04}",
              base05 = "#${palette.base05}",
              base06 = "#${palette.base06}",
              base07 = "#${palette.base07}",
              base08 = "#${palette.base08}",
              base09 = "#${palette.base09}",
              base0A = "#${palette.base0A}",
              base0B = "#${palette.base0B}",
              base0C = "#${palette.base0C}",
              base0D = "#${palette.base0D}",
              base0E = "#${palette.base0E}",
              base0F = "#${palette.base0F}",
          }
      })
    ''
)
