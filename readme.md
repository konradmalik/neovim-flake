# Neovim Flake

## Things to note

-   uses `NVIM_APPNAME` to differentiate from other neovim instances. It's set to `neovim-pde` or `neovim-pde-hm` for
    home-manager (configurable).
-   when running/using `neovim-pde` from the flake directly it runs in 'isolated' mode. Without
    going into much detail, this means that `init.lua` is targeted via `-u` flag. This also means, that your local exrc
    files (eg. `.nvim.lua`) won't be loaded at all. Same for your local config unless you have some files in `$XDG_CONFIG_HOME/$NVIM_APPNAME`. Note that for this reason `NVIM_APPNAME` is neovim-pde by default, but neovim-pde-hm in the home manager module.
-   if isolation is not what you want (eg. I don't want that during my day-to-day work since I rely on per-project `.nvim.lua`) then use the home-manager module, which links the configuration to your `XDG_CONFIG_HOME` folder and loads it from there.

## Credits

Inspired by:

-   https://primamateria.github.io/blog/neovim-nix/
