{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    vimAlias = true;
    viAlias = true;

    options = {
      number = true;

      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;

      mouse = "a";

      ignorecase = true;

      cursorline = true;
    };

    plugins = {
      lightline.enable = true;
      gitgutter.enable = true;
      #lint.enable = true;
      ledger.enable = true;
      nix.enable = true;
      treesitter.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      rust-vim
      ale
      vim-unimpaired
    ];
  };
}

