{
  lib,
  stdenv,
  symlinkJoin,
  grammars,
}:

let
  skippedGrammars = [
    # https://github.com/marsam/tree-sitter-grammars/pull/4
    "tree-sitter-bitbake"
    # hash mismatch as of 2025-10-17
    "tree-sitter-ssh_client_config"
  ];

  filteredGrammars = lib.filterAttrs (n: v: !builtins.any (s: s == v.pname) skippedGrammars) grammars;

  repackGrammars =
    grammars:
    let
      toLang = name: lib.removePrefix "tree-sitter-" name;
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    lib.mapAttrs (
      _: pkg:
      let
        lang = toLang pkg.pname;
      in
      stdenv.mkDerivation {
        inherit (pkg) version meta;
        pname = "${pkg.pname}-nvim";
        src = pkg;
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          mkdir -p $out/parser
          mkdir $out/queries
          ln -s $src/lib/lib${pkg.pname}${ext} $out/parser/${lang}${ext}
          # workaround for https://github.com/marsam/tree-sitter-grammars/pull/5
          if [ -d $src/share/tree-sitter/queries/queries/${lang} ]; then
            ln -s $src/share/tree-sitter/queries/queries/${lang} $out/queries/
          elif [ -d $src/share/tree-sitter/queries/${lang} ]; then
            ln -s $src/share/tree-sitter/queries/${lang} $out/queries/
          else
            rm -rf $out/queries
          fi
        '';
      }
    ) grammars;

  grammarPlugins = repackGrammars filteredGrammars;
in
symlinkJoin {
  name = "tree-sitter-grammars";
  paths = builtins.attrValues grammarPlugins;
}
