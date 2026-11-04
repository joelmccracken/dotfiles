{ ... }:
{
  virtualisation.docker.enable = true;

  # Docker Desktop resolves `host.docker.internal` for containers;
  # plain Linux docker does not.
  # 172.17.0.1 is the docker0 bridge gateway (the host from inside container)
  networking.hosts = {
    "172.17.0.1" = [ "host.docker.internal" ];
  };

  # Talk to the daemon socket without sudo.  The `docker` group itself is
  # created by virtualisation.docker.enable above.
  users.users.joel.extraGroups = [ "docker" ];
}
