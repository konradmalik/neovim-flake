{ lib, pluginsList }:
let
  makePlugin =
    p:
    let
      pluginAttrset = if p ? plugin then p else { plugin = p; };
      deps = if pluginAttrset ? deps then pluginAttrset.deps else [ ];
      depsAttrsets = builtins.map makePlugin deps;
    in
    depsAttrsets ++ [ (lib.filterAttrs (n: v: n != "deps") pluginAttrset) ];

  process =
    madePlugins:
    let
      flat = lib.unique (lib.flatten madePlugins);
      plugins = builtins.map (lib.filterAttrs (n: v: n != "systemDeps")) flat;
      systemDeps = builtins.map (a: if a ? systemDeps then a.systemDeps else [ ]) flat;
    in
    {
      inherit plugins;
      systemDeps = lib.unique (lib.flatten systemDeps);
    };
in
process (builtins.map makePlugin pluginsList)
