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
  myLibxml2 = nixpkgsOld.libxml2.overrideAttrs (oldAttrs: rec {
    version = "2.9.4";
    src = fetchurl {
      url = "http://xmlsoft.org/sources/${oldAttrs.pname}-${version}.tar.gz";
      sha256 = "sha256-/7kRGR5Qm5Zt61XecFOH8UFW4aVrIYJDV83wBTIzYzw=";
    };
  });
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
  env = with nixpkgsOld; bundlerEnv {
    name = "nix-ruby-bundler-env";
    ruby = myRuby;
    gemfile  = ./project/Gemfile;
    lockfile = ./project/Gemfile.lock;
    gemset   = ./gemset.nix;
    gemConfig = defaultGemConfig // {
      nokogiri = attrs: {
        buildFlags = [
          "--use-system-libraries"
          "--with-zlib-lib=${zlib.out}/lib"
          "--with-zlib-include=${zlib.dev}/include"
          "--with-xml2-lib=${myLibxml2.out}/lib"
          "--with-xml2-include=${myLibxml2.dev}/include/libxml2"
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
