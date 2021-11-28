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
    ruby = myRuby;
    gemfile  = ./project/Gemfile;
    lockfile = ./project/Gemfile.lock;
    gemset   = ./gemset.nix;
    gemConfig = nixpkgsOld.defaultGemConfig // {
      nokogiri = attrs: {
        buildFlags = [
          "--use-system-libraries"
          "--with-zlib-lib=${zlib.out}/lib"
          "--with-zlib-include=${zlib.dev}/include"
          "--with-xml2-lib=${libxml2.out}/lib"
          "--with-xml2-include=${libxml2.dev}/include/libxml2"
          "--with-xslt-lib=${libxslt.out}/lib"
          "--with-xslt-include=${libxslt.dev}/include"
          "--with-exslt-lib=${libxslt.out}/lib"
          "--with-exslt-include=${libxslt.dev}/include"
        ] ++ lib.optionals stdenv.isDarwin [
          "--with-iconv-dir=${libiconv}"
          "--with-opt-include=${libiconv}/include"
        ];
      };
    };
  };
in stdenv.mkDerivation {
  name = "nix-ruby";
  buildInputs = [
    myRuby
    env
  ];
}
