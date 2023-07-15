# Neovim Flake

## Things to note

-   uses `NVIM_APPNAME` to differentiate from other neovim instances. It's set to `neovim-pde` or `neovim-pde-hm` for
    home-manager (configurable).
-   when running/using `neovim-pde` from the flake directly it runs in 'isolated' mode. Without
    going into much detail, this means that it append its config in nix store to your `$XDG_CONFIG_DIRS` and use `-u`
    flag to force-load this specific `init.lua`.
    This means that any `init.lua` in your local `$XDG_CONFIG_HOME/$NVIM_APPNAME` won't be loaded, even if `$NVIM_APPNAME` is `neovim-pde`
    (I think that `after` folders and others that don't need to be required explicitly will be loaded, but I've never tested this).
    That also means that `exrc` functionality won't work (eg. `.nvim.lua` files won't be loaded automatically).
    If you rely on that feature (I do) then consider using the provided home-manager module.
-   if isolation is not what you want, then use the home-manager module, which links the configuration to your `XDG_CONFIG_HOME` folder and loads it from there.

## Credits

Inspired by:

-   https://primamateria.github.io/blog/neovim-nix/
