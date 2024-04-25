{ pkgs }:
pkgs.writeTextDir "lua/konrad/skeletons.lua" /* lua */ ''
  return "${../../skeletons}"
''
