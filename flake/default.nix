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
        inherit system;
        overlays = [
          inputs.gen-luarc.overlays.default
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
