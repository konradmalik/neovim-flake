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
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
