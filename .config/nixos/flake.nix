{
  description = "Portable NixOS modules, consumed by a machine's private system config";

  # Deliberately no inputs (for now)

  outputs = { self, ... }: {
    nixosModules = {
      docker = ./modules/docker.nix;

      # Everything at once, for a machine that wants the lot.  Import the
      # individual modules instead to take them piecemeal.
      default = {
        imports = [ self.nixosModules.docker ];
      };
    };
  };
}
