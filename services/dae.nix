{ ... }:

{
  # linux的clash
  services.dae = {
    enable = true;
    configFile = ./config.dae;
    openFirewall = {
      enable = true;
      port = 10880;
    };
  };
}