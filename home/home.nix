{ pkgs, ... }:
let
  usr = "ff";
  host = "fnix";
in
{
  # 注意修改这里的用户名与用户目录
  home.username = "${usr}";
  home.homeDirectory = "/home/${usr}";

  imports = [
    ./git/git.nix
  ];

  nixpkgs = {
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      # allowUnfreePredicate = _: true;
    };
  };

  home.packages = with pkgs; [
    # kitty
    # glfw
    # gtk3
    # mesa
    # mesa-utils
    # glxgears
    tree
    neofetch
    nixfmt-rfc-style
    nil
    wl-clipboard
    # xclip
    # xorg.xeyes
  ];

  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
