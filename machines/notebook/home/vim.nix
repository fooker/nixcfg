{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    vimAlias = true;
    viAlias = true;

    opts = {
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
      ledger.enable = true;
      treesitter.enable = true;
      lsp-lines.enable = true;
      lsp-format.enable = true;
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          marksman.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      ale
      vim-unimpaired
    ];
  };
}

