{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    vimAlias = true;
    withPython3 = true;

    plugins = [
      pkgs.python3Packages.editorconfig
      pkgs.vimPlugins.lightline-vim
      pkgs.vimPlugins.ale
      pkgs.vimPlugins.gitgutter
      pkgs.vimPlugins.vim-nix
      pkgs.vimPlugins.rust-vim
      pkgs.vimPlugins.vim-unimpaired
    ];
    extraConfig = ''
      set nu
      set ignorecase
      set mouse=a

      set undodir=~/.cache/vim/
      set undofile
      set undolevels=100
      set undoreload=1000

      set cursorline
      hi CursorLine cterm=NONE ctermbg=238 ctermfg=NONE
    '';
  };
}
