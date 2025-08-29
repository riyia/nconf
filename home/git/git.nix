{...} :

{
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
    home.file.".gitconfig".source = ./.gitconfig;
}