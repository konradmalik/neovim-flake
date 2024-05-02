{ pkgs }:
pkgs.writeTextDir "lua/pde/skeletons.lua" # lua
  ''
    return "${../../skeletons}"
  ''
