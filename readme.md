# Neovim Flake

## Things to note

-   uses `NVIM_APPNAME` to differentiate from other neovim instances. It's set to `neovim-pde` but can be changed via
`override` function call on `neovim-pde` package. See Home-manager module as it uses it.
-   when running/using `neovim-pde` from the flake directly (and without `override`) it runs in 'isolated' mode. Without
    going into much detail, this means that `init.lua` is targeted via `-u` flag. This also means, that your local exrc
    files (eg. `.nvim.lua`) won't be loaded at all. Same goes for your local configuration.
-   if isolation is not what you want (eg. I don't want that during my day-to-day work since I rely on per-project `.nvim.lua`) then use the home-manager module, which links the configuration to your `XDG_CONFIG_HOME` folder

## Credits

Inspired by:

-   https://primamateria.github.io/blog/neovim-nix/
