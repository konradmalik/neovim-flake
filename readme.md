[![Actions Status](https://github.com/konradmalik/neovim-flake/actions/workflows/linux.yml/badge.svg)](https://github.com/konradmalik/neovim-flake/actions)
[![Actions Status](https://github.com/konradmalik/neovim-flake/actions/workflows/darwin.yml/badge.svg)](https://github.com/konradmalik/neovim-flake/actions)

# Neovim Flake

Neovim in nix.

Try it out:

```bash
$ nix run github:konradmalik/neovim-flake
```

Run checks (stylua, luacheck, typecheck via lua-language-server):

```bash
$ make check-fmt
$ make check-lint
```

Run tests (busted using nvim as an interpreter):

```bash
$ make test
```

## Assumptions

- keeps all Neovim config in lua as it's supposed to be
- uses nix for system dependencies, plugins and packaging

That way nix is a layer on top, just used for packaging and reproducibility. It does not interfere with the standard way
to configure Neovim.

## Language servers, formatters, linters

Those are managed by nix and appended to the end of PATH for Neovim.
This allows Neovim to use them, but also to use other versions by prepending them to PATH.

An example - you can have some project which uses an older version of `black` which formats files a bit differently.
Assuming that this project has a devshell defined, you can just enter that devshell and run Neovim.
The older `black` from the devshell will take precedence over the one provided by this flake, because devshell works by
prepending to PATH.

## Things to note

- Uses `NVIM_APPNAME` to differentiate from other Neovim instances. It's set to `neovim-pde` or `neovim-pde-hm` for
  home-manager (configurable) or `nvim` when running in "dev mode".

### Home Manager

There is a home-manager module provided, which links the configuration to your `XDG_CONFIG_HOME` folder and loads it from there.

This is the recommended way to use this flake "day-to-day" in your NixOS system.

### Self-contained mode

When running/using `neovim-pde` from the flake directly it runs in `self-contained` mode.

This means that it appends its config in nix store to your `$XDG_CONFIG_DIRS` and use `-u` flag to force-load this specific `init.lua`.
This means that any `init.lua` in your local `$XDG_CONFIG_HOME/$NVIM_APPNAME` won't be loaded, even if `$NVIM_APPNAME` is `neovim-pde`
(I think that `after` folders and others that don't need to be required explicitly will be loaded, so those should work if put to the proper `$NVIM_APPNAME` folder, but I've never tested this).

That also means that `exrc` functionality won't work (e.g. local `.nvim.lua` files won't be loaded automatically).
If you rely on that feature (I sometimes do) then consider using the provided home-manager module.

## Experimentation

One of the cons of using Neovim in nix is - no "dirty" modifications to Neovim to try something out quickly. Experimentation becomes harder.
You always need to rebuild it, but `nix build` and then `./result/bin/nvim` is quick and easy enough for it to not be a deal-breaker.

Another solution implemented in this repo is `nvim-dev` command that becomes available inside devShell here.
It runs the neovim package defined in the repo with plugins and `nix`-generated lua files provided, but the native lua
config gets read "live" from `./config/nvim` here in the repo. This allows for instant feedback and dynamic
development just like when using neovim without nix.

## Notes

> composed of my reddit posts

What's great in using Neovim through nix is a way to generate lua files from nix. It allows configuring LSP to use binaries directly from nix store as opposed to getting them from PATH, especially useful for the most common LSPs that I always expect to have.

What I don't like in those "nixvim" flakes is that people most often use only nix for everything. While most certainly you can generate all of your config, all of your lua files from nix, I think it's a bad idea since you lose all completion, diagnostics, and all neodev niceness for lua.

## Credits

Inspired by:

- https://primamateria.github.io/blog/neovim-nix/
