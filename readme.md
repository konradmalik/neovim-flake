# Neovim Flake

## Things to note

-   uses `NVIM_APPNAME` to differentiate from other neovim instances. It's set to `neovim-pde` or `neovim-pde-hm` for
    home-manager (configurable).
-   when running/using `neovim-pde` from the flake directly it runs in 'isolated' mode. Without
    going into much detail, this means that it will override your `$XDG_CONFIG_HOME` with a nix-store path, so your git config, shell config etc. won't be available in neovim, nor in neovim's terminal.
    This also means that any files in your local `$XDG_CONFIG_HOME/$NVIM_APPNAME` won't be loaded, even if `$NVIM_APPNAME` is `neovim-pde`.
-   if isolation is not what you want, then use the home-manager module, which links the configuration to your `XDG_CONFIG_HOME` folder and loads it from there.

## Credits

Inspired by:

-   https://primamateria.github.io/blog/neovim-nix/
