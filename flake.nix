{
  description = "Typst uni devShells";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        llvm = pkgs.llvmPackages_latest;
        lib = nixpkgs.lib;
      in {
        devShell = pkgs.mkShell rec {
          nativeBuildInputs = [
            llvm.clang-tools
            llvm.clang
            llvm.libcxx
          ];

          packages = [
            pkgs.lldb
            pkgs.typst
            pkgs.typstyle
          ];

          CLANGD_FLAGS = "--query-driver=${pkgs.clang}/bin/clang";
          CPATH = builtins.concatStringsSep ":" [
            (lib.makeSearchPathOutput "dev" "include" nativeBuildInputs)
          ];
        };
      }
    );
}
