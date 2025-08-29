{
  config,
  lib,
  pkgs,
  ...
}:
let
  usr = "ff";
  host = "fnix";
in
{
  imports = [
    # include NixOS-WSL modules
    # <nixos-wsl/modules>
  ];

  users.users."${usr}" = {
    isNormalUser = true;
    description = "${usr}";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
    ];
  };

  # wsl = {
  #   enable = true;
  #   defaultUser = "${usr}";
  #   wslConf = {
  #     user.default = "${usr}";
  #     network.hostname = "${host}";
  #   };
  #   useWindowsDriver = true;
  # };

  environment.systemPackages = with pkgs; [
    wget
    curl
  ];

  programs = {
    bash.completion.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      defaultEditor = true;
    };
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
    };
    nano.enable = false;
  };

  nix.settings = {
    trusted-users = [ "${usr}" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "25.05";
}
