{
  description = "Python packages in PythonEDA";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda = {
      url = "github:rydnr/pythoneda/0.0.1a5";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "flake-utils";
    };
    pythoneda-git-repositories = {
      url = "github:rydnr/pythoneda-git-repositories/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "flake-utils";
    };
    pythoneda-nix-shared = {
      url = "github:rydnr/pythoneda-nix-shared/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description = "Python packages in PythonEDA";
        license = pkgs.lib.licenses.gpl3;
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-python-packages = pythonPackages.buildPythonPackage rec {
            pname = "pythoneda-python-packages";
            version = "0.0.1a2";
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = [ pkgs.poetry ];

            propagatedBuildInputs = with pythonPackages; [
              pythoneda.packages.${system}.pythoneda
              pythoneda-git-repositories.packages.${system}.pythoneda-git-repositories
              pythoneda-nix-shared.packages.${system}.pythoneda-nix-shared
            ];
            pythonImportsCheck = [ ];

            meta = with pkgs.lib; {
              inherit description license homepage maintainers;
            };
          };
          default = packages.pythoneda-python-packages;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}
