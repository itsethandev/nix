{
  inputs,
  lib,
  ...
}: {
  home = lib.genAttrs ["turing" "newton"] (_: {
    config,
    lib,
    options,
    ...
  }: {
    programs.opencode = {
      enable = lib.mkDefault true;
      cli = {
        plugins = lib.mkIf config.programs.herdr.enable [
          "${config.xdg.configHome}/opencode/herdr-opencode"
        ];
        theme.name = lib.mkIf (options ? stylix.enable && config.stylix.enable) (lib.mkDefault "stylix");
      };
      context = ../static/ai/AGENTS.md;
      skills = inputs.its-skills + "/skills";
      settings.permission.question = lib.mkDefault "deny";
    };
  });
}
