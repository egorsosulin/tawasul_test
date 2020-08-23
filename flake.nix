{
  description = "A flake for my FoundationDB";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.03;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        pname = "foundationdb";
        version = "6.2.22";

        src = fetchurl {
          url = "https://www.foundationdb.org/downloads/6.2.22/linux/fdb_6.2.22.tar.gz";
          sha256 = "1b4e14b59ecec1ff225500b87d20cb5ec987d4d9e24760fe77a35815d23aca82";
        };

        phases = [ "installPhase" ];
        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          tar -xzf $src
          rm fdb_binaries/*.sha256
          mv fdb_binaries/* ./
          rmdir fdb_binaries
          chmod a+x *

          for file in `ls -1` ; do
            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $file || true
            install -t $out/bin $file
          done
        '';
      };

  };
}
