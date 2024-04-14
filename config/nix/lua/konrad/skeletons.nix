{ pkgs }:
pkgs.writeTextDir "lua/konrad/skeletons.lua" ''
  return "${../../skeletons}"
''
