with (import <nixpkgs> {});
let
  nixpkgsOld = (import (builtins.fetchGit {
    # Descriptive name to make the store path easier to identify
    name = "nixos-old";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "001c0cbe54228f88d5634f431fcaf460b8ff4590";
  }) {});
  rubyVersionParse = import <nixpkgs/pkgs/development/interpreters/ruby/ruby-version.nix> { inherit lib; };
  myRuby = nixpkgsOld.pkgs.ruby_2_5.overrideAttrs (oldAttrs: rec {
        version = rubyVersionParse "2" "5" "5" "";
        ver = version;
        tag = ver.gitTag;
        src = fetchFromGitHub {
          owner  = "ruby";
          repo   = "ruby";
          rev    = tag;
          sha256 = "sha256-/xvv/v8ZgMCRJNWjH7kNbONCTHTwvSM0pns/RHY/61A=";
        };
        useRailsExpress = false;
        docSupport = false;
        rubygemsSupport = false;
    });
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
