{
  description = "Larstop NixOS Flake";
  inputs = {
    #nixos.url = "nixpkgs/nixos-23.11";
    unstable.url = "nixpkgs/nixos-unstable";
    #master.url = "nixpkgs/master";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix  ];
      };
    };
  };
}
