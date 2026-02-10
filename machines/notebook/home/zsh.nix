{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    defaultKeymap = "emacs";

    autosuggestion.enable = true;
    enableCompletion = true;

    autocd = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = false;
    };

    shellAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };

    initContent = ''
      # Colorify the prompt
      autoload -U colors && colors

      # Allow expressions in prompts
      setopt prompt_subst

      # Specify a simple prompt on left side
      PROMPT=""
      PROMPT+='%{%F{green}%}%m%{%f%} '
      PROMPT+='%{%F{blue}%B%}%3~%{%b%f%} '
      PROMPT+='%{%(!.%F{red}.%F{green})%B%}>%{%b%f%} '

      # Enable git prompt on right side
      RPROMPT='$(${pkgs.gitprompt-rs}/bin/gitpromtp-rs)'

      # Search only for first word
      bindkey '^[OA' up-line-or-search
      bindkey '^[OB' down-line-or-search
    '';
  };
}
