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
          inputs.neorocks.overlays.default
          (final: prev: {
            # until it's fixed for darwin
            zls = final.stable.zls;
            stable = import inputs.nixpkgs-stable {
              system = final.system;
              config = final.config;
            };
          })
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
