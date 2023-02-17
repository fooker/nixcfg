{
  programs.git = {
    enable = true;

    userEmail = "fooker@lab.sh";
    userName = "Dustin Frisch";

    extraConfig = {
      core.whitespace = "trailing-space,space-before-tab";
      core.fsmonitor = true;

      pull.rebase = true;

      init.defaultBranch = "main";
    };

    lfs.enable = true;

    signing = {
      key = "fooker@lab.sh";
      signByDefault = true;
    };
  };
}
