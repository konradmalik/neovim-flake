{ pkgs }:
let
  debugpy = pkgs.python3.withPackages (p: [ p.debugpy ]);
in
pkgs.writeTextDir "lua/pde/debugpy.lua" # lua
  ''
    return {
        python = "${debugpy}/bin/python",
    }
  ''
