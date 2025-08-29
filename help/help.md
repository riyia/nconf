# 帮助手册

## 启用wsl
```
wsl --install --no-distribution
```

### 下载内核包
一般不用下，后面的wsl包里有  
[wsl_update_x64.msi](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)


### 设置默认版本
一般都会自动下载最新版，跳过
```
wsl --set-default-version 2
wsl --update
```

## 设置.wslconfig
不是全部配置，安装nixos的wsl包后可以运行 `wsl settings` 再进行设置
```.wslconfig
# Settings apply across all Linux distros running on WSL 2
[wsl2]

# Limits VM memory to use no more than 4 GB, this can be set as whole numbers using GB or MB
memory=4GB

# Sets the VM to use two virtual processors
processors=2

# Sets amount of swap storage space to 8GB, default is 25% of available RAM
swap=2GB

# Turn on default connection to bind WSL 2 localhost to Windows localhost
# localhostforwarding=true

ipv6=true
# mirrored模式可能会导致win无法识别wsl转发的端口，但是不用mirrored模式就没法代理，然后就可能没法连到github什么的
networkingMode=mirrored
# dnsTunneling=true
firewall=false
# net模式不支持代理，这里好像没用
# autoProxy=true
defaultVhdSize=137438953472

[experimental]
autoMemoryReclaim=gradual
bestEffortDnsParsing=true
# useWindowsDnsCache=true
```

## 安装nixos的wsl包
https://github.com/nix-community/NixOS-WSL/releases

## 安装改名字
上一步下载wsl包之后可以放到安装位置直接运行  
想改wsl名字也需要先运行安装..
```
wsl --export NixOS nix_bak.tar
wsl --import fnix .\ .\nix_bak.tar --version 2
```

## 设置默认wsl
```
wsl -s fnix
```

## 更新
```bash
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-25.05/nixexprs.tar.xz nixos
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable/nixexprs.tar.xz nixpkgs
# 必须update一次
sudo nix-channel --update

sudo nano /etc/nixos/configuration.nix
sudo nixos-rebuild switch --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
```

### configuration.nix
```configuration.nix
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
    <nixos-wsl/modules>
  ];

  # 这是设置的nixos内部的用户
  users.users."${usr}" = {
    isNormalUser = true;
    description = "${usr}";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
    ];
  };

  # 这是设置的wsl虚拟机的用户
  wsl = {
    enable = true;
    defaultUser = "${usr}";
    wslConf = {
      user.default = "${usr}";
      network.hostname = "${host}";
    };
    useWindowsDriver = true;
  };

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
    # vscode远程连接需要这个
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
```

### 设置ssh
```
ssh-keygen -t ed25519 -C "yria@fufu.moe"
```

### 代理转发
`代理转发功能是由ssh提供的，所以直接运行wsl是使用不了的`  
添加到ssh-agent, 可以不弄这个，代理转发需要  
代理转发：简而言之就是使用`主机A`远程连接到`服务器B`中时，想要使用git推送代码到仓库时要使用ssh，然而`服务器B`并没有配置ssh公钥，这时候就要使用代理转发，将请求转回到`主机A`  
ssh-agent是在`主机A`里使用的，不是`服务器B`  
以下配置都为`主机A`使用
```bash
# linux
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# windows
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-Service ssh-agent
ssh-add c:/Users/ml/.ssh/id_ed25519

# 需要设置远程地址，不然转发不了
vim  C:/Users/ml/.ssh/config
nvim C:/Users/ml/.ssh/config
code C:/Users/ml/.ssh/config
```
```config
# *可以替换为 服务器B ip地址，*是连接到的所有服务器都转发
 Host *
   ForwardAgent yes
```

测试是否有效  
这个会生成一个.ssh/known_hosts文件，vscode使用git推送需要这个
```
ssh -T git@github.com
```


## 复制flake项目
```
nix shell nixpkgs#gitMinimal
git clone git@github.com:riyia/nconf.git
```



## 关闭wsl
```
wsl --shutdown
```

## home-manager复制文件夹方法
file为home目录下的文件夹位置  
source为要复制到文件夹
```home.nix
home.file.".config/nushell/git" = {
    source = ./nushell/git;
    recursive = true;
};
```