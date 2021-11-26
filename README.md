# README

Assuming nix is installed.

## Using direnv hook

Install direnv:


```
nix-env -iA nixpkgs.direnv
```

Follow this setup to hook direnv: https://direnv.net/docs/hook.html

Allow environment script to run

```
direnv allow
```

You will be using nix-shell from `shell.nix` file in this directory

## Without direnv

Build the shell yourself

```
nix-shell <shell.nix file or empty for the default shell.nix location>
```

