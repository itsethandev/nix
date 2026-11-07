{inputs, ...}: {
  flake.modules.homeManager.opencode = {
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
      context = ../../static/ai/AGENTS.md;
      commands = ../../static/ai/prompts;
      skills = inputs.its-skills + "/skills";
      settings.permission.question = lib.mkDefault "deny";
    };
  };
}
