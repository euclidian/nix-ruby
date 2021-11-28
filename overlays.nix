self: super: {
    ruby_2_5 = let
        fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
        rubyVersionParse = import <nixpkgs/pkgs/development/interpreters/ruby/ruby-version.nix> { inherit (super) lib; };
        in
            super.ruby_2_5.overrideAttrs (oldAttrs: rec {
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
                # buildInputs = oldAttrs.buildInputs ++ [super.libxml2];
                # nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [super.libxml2];
            });
}