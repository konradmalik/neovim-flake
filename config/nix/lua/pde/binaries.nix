{ lib, pkgs }:
let
  debugpy = pkgs.python3.withPackages (p: [ p.debugpy ]);
in
pkgs.writeTextDir "lua/pde/binaries.lua" # lua
  ''
    local fs = require("pde.fs")

    local nix = {
        -- formatters
        black = "${lib.getExe pkgs.black}",
        isort = "${lib.getExe pkgs.isort}",
        nixfmt = "${lib.getExe pkgs.nixfmt-rfc-style}",
        prettier = "${lib.getExe pkgs.nodePackages.prettier}",
        rustfmt = "${lib.getExe pkgs.rustfmt}",
        shfmt = "${lib.getExe pkgs.shfmt}",
        stylua = "${lib.getExe pkgs.stylua}",
        taplo = "${lib.getExe pkgs.taplo}",

        -- linters
        golangci_lint = "${lib.getExe pkgs.golangci-lint}",
        jq = "${lib.getExe pkgs.jq}",
        shellcheck = "${lib.getExe pkgs.shellcheck}",

        -- lsps
        clangd = "${lib.getExe' pkgs.clang-tools "clangd"}",
        efm = "${lib.getExe pkgs.efm-langserver}",
        gopls = "${lib.getExe pkgs.gopls}",
        jsonls = "${lib.getExe pkgs.nodePackages.vscode-json-languageserver}",
        ltex_ls = "${lib.getExe' pkgs.ltex-ls "ltex-ls"}",
        lua_ls = "${lib.getExe pkgs.lua-language-server}",
        nixd = "${lib.getExe pkgs.nixd}",
        pyright = "${lib.getExe' pkgs.pyright "pyright-langserver"}",
        roslyn_ls = "${lib.getExe pkgs.roslyn-ls}",
        rust_analyzer = "${lib.getExe pkgs.rust-analyzer}",
        terraformls = "${lib.getExe pkgs.terraform-ls}",
        yamlls = "${lib.getExe pkgs.yaml-language-server}",
        zls = "${lib.getExe pkgs.zls}",

        -- debuggers
        debugpy = "${debugpy}/bin/python",
        delve = "${lib.getExe' pkgs.delve "dlv-dap"}",
        netcoredbg = "${lib.getExe pkgs.netcoredbg}",

        -- other
        node = "${lib.getExe pkgs.nodejs-slim}",
    }

    local function get_lazily(binary)
      return function()
        local exe = fs.from_path_or_default(binary, nix[binary])
        if not exe then
          vim.notify("cannot find '" .. binary .. "' binary in PATH nor in binaries.lua", vim.log.levels.ERROR)
        end
        return exe
      end
    end

    local ret = {}

    setmetatable(ret, {
      __index = function(tbl, key)
        return get_lazily(key)
      end,
    })

    return ret
  ''
