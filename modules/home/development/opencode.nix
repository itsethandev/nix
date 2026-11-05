{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.development;
in {
  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = lib.mkDefault true;
      context = ../../../static/ai/AGENTS.md;
      skills = inputs.its-skills + "/skills";
      settings.permission.question = lib.mkDefault "deny";
    };
  };
}
