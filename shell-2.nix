# Achieve the same thing with shell.nix, but with using overlays pattern.
# nixpkgsOld.pkgs.ruby_2_5 in this case using the recipe from old nixpkgs repo.
# by default ruby_2_5 will use ruby 2.5.8. The overlays is overriding the source build
# so that it builds ruby 2.5.5
with (import <nixpkgs> {});
let
  nixpkgsOld = (import (builtins.fetchGit {
    # Descriptive name to make the store path easier to identify
    name = "nixos-old";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "001c0cbe54228f88d5634f431fcaf460b8ff4590";
  }) {
    overlays = [ (import ./overlays.nix) ];
  });
  myRuby = nixpkgsOld.pkgs.ruby_2_5;
  env = bundlerEnv {
    name = "nix-ruby-bundler-env";
    inherit myRuby;
    gemfile  = ./project/Gemfile;
    lockfile = ./project/Gemfile.lock;
    gemset   = ./gemset.nix;
  };
in stdenv.mkDerivation {
  name = "nix-ruby";
  buildInputs = [
    myRuby
    env
  ];
}
