{
  description = "flake config";

  nixConfig = {
    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # 自建仓库
    ffpkgs = {
      url = "github:riyia/ffpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      ffpkgs,
      ...
    }@inputs:
    let
      usr = "ff";
      host = "fnix";
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [

            # 引入自建仓库 : pkgs.ffpkgs.package
            ({
              nixpkgs.overlays = [
                (final: prev: {
                  ffpkgs = inputs.ffpkgs.packages."${prev.system}";
                })
              ];
            })

            ./configuration.nix
            ./services

            nixos-wsl.nixosModules.default
            {
              wsl = {
                enable = true;
                defaultUser = "${usr}";
                wslConf = {
                  user.default = "${usr}";
                  network.hostname = "${host}";
                };
                useWindowsDriver = true;
              };
            }

            # 将 home-manager 配置为 nixos 的一个 module
            # 这样在 nixos-rebuild switch 时，home-manager 配置也会被自动部署
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users."${usr}" = import ./home/home.nix;

              # 使用 home-manager.extraSpecialArgs 自定义传递给 ./home.nix 的参数
              # 取消注释下面这一行，就可以在 home.nix 中使用 flake 的所有 inputs 参数了
              home-manager.extraSpecialArgs = inputs;
            }

            {
              # given the users in this list the right to specify additional substituters via:
              #    1. `nixConfig.substituters` in `flake.nix`
              nix.settings.trusted-users = [ "${usr}" ];
            }
          ];
        };
      };
    };
}
