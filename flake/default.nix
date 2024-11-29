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
        config = {
          # from roslyn-ls
          permittedInsecurePackages = [
            "dotnet-core-combined"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-7.0.410"
            "dotnet-sdk-wrapped-6.0.428"
          ];
        };
        overlays = [
          inputs.gen-luarc.overlays.default
          inputs.neorocks.overlays.default
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
