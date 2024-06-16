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
          # until https://github.com/NixOS/nixpkgs/issues/317055
          (final: prev: {
            zig_0_12 = prev.zig_0_12.overrideAttrs (_oldAttrs: {
              preConfigure = ''
                CC=$(type -p $CC)
                CXX=$(type -p $CXX)
                LD=$(type -p $LD)
                AR=$(type -p $AR)
              '';
            });
          })
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    };
}
