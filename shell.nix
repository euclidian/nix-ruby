with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "nix-ruby-bundler-env";
    inherit ruby;
    gemfile  = ./project/Gemfile;
    lockfile = ./project/Gemfile.lock;
    gemset   = ./gemset.nix;
  };
in stdenv.mkDerivation {
  name = "nix-ruby";
  buildInputs = [ env ];
}
