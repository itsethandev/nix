{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.development;
in {
  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = lib.mkDefault true;
      cli = {
        plugins = lib.mkIf config.programs.herdr.enable [
          (toString (pkgs.writeTextDir "tui.js" ''
            export { default } from ${builtins.toJSON "file://${config.xdg.configHome}/opencode/herdr-tui-session.js"};
          ''))
        ];
        theme.name = lib.mkDefault "stylix";
      };
      context = ../../../static/ai/AGENTS.md;
      skills = inputs.its-skills + "/skills";
      settings.permission.question = lib.mkDefault "deny";
    };
  };
}
