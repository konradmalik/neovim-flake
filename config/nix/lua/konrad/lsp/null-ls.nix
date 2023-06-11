# vim: ft=lua
{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/null-ls.lua" ''
  -- https://github.com/jose-elias-alvarez/null-ls.nvim
  local null_ls_ok, null_ls = pcall(require, "null-ls")
  if not null_ls_ok then
      vim.notify("cannot load null-ls")
      return
  end

  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics
  local code_actions = null_ls.builtins.code_actions

  -- null_ls has a 'should_attach' fuction where we could limit
  -- the number of buffers it attaches to but we need it in all buffers in
  -- fact due to gitsigns
  null_ls.setup({
      debug = false,
      sources = {
          -- always available
          formatting.prettier.with({
            command = "${pkgs.nodePackages.prettier}/bin/prettier",
            timeout = 10000,
            extra_filetypes = { "toml" },
            extra_args = { "--plugin-search-dir", "${pkgs.nodePackages.prettier-plugin-toml}/lib" },
          }),
          formatting.shfmt.with({
            command = "${pkgs.shfmt}/bin/shfmt",
          }),

          diagnostics.shellcheck.with({
            command = "${pkgs.shellcheck}/bin/shellcheck",
          }),

          code_actions.gitsigns,
          code_actions.shellcheck.with({
            command = "${pkgs.shellcheck}/bin/shellcheck",
          }),

          -- per project can be added in .nvim.lua via "register" function
          -- which takes a table of sources
      },
  })
''
