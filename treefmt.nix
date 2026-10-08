{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    stylua.enable = true;
    prettier = {
      enable = true;
      includes = [
        "*.json"
        "*.md"
        "*.yaml"
        "*.yml"
      ];
    };
    shfmt = {
      enable = true;
      useEditorConfig = true;
      includes = [ "*.sh" ];
    };
    shellcheck = {
      enable = true;
      includes = [ "*.sh" ];
    };
  };
}
