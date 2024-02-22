[![Actions Status](https://github.com/konradmalik/neovim-flake/actions/workflows/linux.yml/badge.svg)](https://github.com/konradmalik/neovim-flake/actions)
[![Actions Status](https://github.com/konradmalik/neovim-flake/actions/workflows/darwin.yml/badge.svg)](https://github.com/konradmalik/neovim-flake/actions)

# Neovim Flake

Neovim in nix.

Try it out:

```bash
$ nix run github:konradmalik/neovim-flake
```

## Assumptions

-   keeps all Neovim config in lua as it's supposed to be
-   uses nix for system dependencies, plugins and packaging

That way nix is a layer on top, just used for packaging and repoducibility. It does not interfere with the standard way
to configure Neovim.

## Things to note

-   uses `NVIM_APPNAME` to differentiate from other Neovim instances. It's set to `neovim-pde` or `neovim-pde-hm` for
    home-manager (configurable).

### Home Manager

The provided home-manager module, which links the configuration to your `XDG_CONFIG_HOME` folder and loads it from there.

This is the recommended way to use this flake "day-to-day" in your NixOS system.

### Isolated mode

When running/using `neovim-pde` from the flake directly it runs in 'isolated' mode.

Without going into much detail, this means that it append its config in nix store to your `$XDG_CONFIG_DIRS` and use `-u`
flag to force-load this specific `init.lua`.
This means that any `init.lua` in your local `$XDG_CONFIG_HOME/$NVIM_APPNAME` won't be loaded, even if `$NVIM_APPNAME` is `neovim-pde`
(I think that `after` folders and others that don't need to be required explicitly will be loaded, so those should work if put to the proper `$NVIM_APPNAME` folder, but I've never tested this).

That also means that `exrc` functionality won't work (eg. local `.nvim.lua` files won't be loaded automatically).
If you rely on that feature (I sometimes do) then consider using the provided home-manager module.

## Experimentation

One of the cons of using Neovim in nix is - no "dirty" modifications to Neovim to try something out quickly. Experimentation becomes harder.
You always need to rebuild it, but `nix build` and then `./result/bin/nvim` is quick and easy enough for it to not be a deal-breaker.

Alternatively, one can just copy the whole config to a new $NVIM_APPNAME, modify whatever, and then "port" those changes back to nix once experimentation is finished.

## Notes

> composed from my reddit posts

As a home-manager module - it's a great idea and it works as I expect.

For `nix run .` type of usage (isolated and fully configured Neovim that I can run wherever) has some minor problems
like: because `-u` is used, Neovim does not load .nvim.lua (or anything mentioned in exrc)

What's great in using Neovim through nix is a way to generate lua files from nix. It allows to configure LSP to use binaries directly from nix store as opposed to getting them from PATH, especially useful for the most common LSPs that I always expect to have.

What I don't like in Nix-Neovim flakes is that people most often use only nix for everything. While most certainly you can generate all of your config, all of your lua files from nix, I think it's a bad idea since you lose all completion, diagnostics, and all neodev niceness for lua.

## Credits

Inspired by:

-   https://primamateria.github.io/blog/neovim-nix/
