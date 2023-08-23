{ pkgs, nativeConfig }:
pkgs.writeTextDir "lua/konrad/skeletons.lua" ''
  return "${nativeConfig}/skeletons"
''
