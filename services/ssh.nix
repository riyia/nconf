{ ... }:
let
  usr = "ff";
in
{
  users.users."${usr}".openssh.authorizedKeys.keys = [
    # replace with your own public key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpucT5gST7D0n8eaK+4hlzRwVXRrHYyEQzrVWQyuf+2 yria@fufu.moe"
  ];
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };
}
