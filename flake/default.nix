{ inputs, ... }:
{
  imports = [
    ./apps.nix
    ./checks.nix
    ./devshells.nix
    ./homeManagerModules.nix
    ./packages
  ];

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        config = {
          permittedInsecurePackages = [
            # from roslyn-ls
            "dotnet-sdk-6.0.428"
          ];
        };
        inherit system;
        overlays = [
          inputs.gen-luarc.overlays.default
          inputs.neorocks.overlays.default
          (final: prev: {
            # FIXME https://nixpk.gs/pr-tracker.html?pr=368248
            lua-language-server =
              (builtins.getFlake "github:nixos/nixpkgs/1a9767900c410ce390d4eee9c70e59dd81ddecb5")
              .legacyPackages.${prev.system}.lua-language-server;
          })
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
