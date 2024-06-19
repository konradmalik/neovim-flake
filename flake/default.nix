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
        overlays = [ ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
