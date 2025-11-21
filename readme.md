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
- uses nix for system dependencies, plugins, and packaging

That way nix is a layer on top, just used for packaging and reproducibility. It does not interfere with the standard way
to configure Neovim.

## Language servers, formatters, linters

Those are managed by nix and appended to the end of PATH for Neovim.
This allows Neovim to use them, but also to use other versions by prepending them to PATH.

An example - you can have some project which uses an older version of `black` which formats files a bit differently.
Assuming that this project has a devshell defined, you can just enter that devshell and run Neovim.
The older `black` from the devshell will take precedence over the one provided by this flake, because devshell works by
prepending to PATH.

## Experimentation

One of the cons of using Neovim in nix is - no "dirty" modifications to Neovim to try something out quickly. Experimentation becomes harder.
You always need to rebuild it, but `nix build` and then `./result/bin/nvim` is quick and easy enough for it to not be a deal-breaker.

Another solution implemented in this repo is `nvim-dev` command that becomes available inside devShell here.
It runs the neovim package defined in the repo with `plugins` and `extraPackages` provided, but the native lua
config gets read "live" from `~/.config/nvim-dev` which is linked to `nvim` folder here in the repo.
This allows for instant feedback and dynamic development just like when using neovim without nix.

## Credits

Inspired by:

- https://primamateria.github.io/blog/neovim-nix/
- https://github.com/nix-community/kickstart-nix.nvim/
