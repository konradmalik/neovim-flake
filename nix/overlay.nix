{
  inputs,
}:
final: prev:
(
  let
    pkgs = final.pkgs;
    lib = pkgs.lib;
  in
  (import ./default.nix { inherit pkgs lib inputs; })
)
