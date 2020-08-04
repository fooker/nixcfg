{ ... }:

{
  programs.git = {
    enable = true;

    userEmail = "fooker@lab.sh";
    userName = "Dustin Frisch";
    
    # delta = {
    #   enable = true;
    #   options = [ "--dark" ];
    # };

    extraConfig = {
      core = {
        whitespace = "trailing-space,space-before-tab";
      };
    };

    lfs.enable = true;

    signing = {
      key = "fooker@lab.sh";
      signByDefault = true;
    };
  };
}