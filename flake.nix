{
  description = "Typst uni devShells";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {pkgs, ...}: let
        alias = pkgs.writeShellScriptBin;
      in {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [(alias "compile" ''typst compile ./src/thesis.typ ./thesis.pdf'')];
          buildInputs = with pkgs; [
            typst
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          # shellHook = ''
          #   setsid typst watch ./src/main.typ
          #   setsid zathura ./main.pdf
          # '';
        };
      };
      imports = [];
      flake = {};
    };
}
