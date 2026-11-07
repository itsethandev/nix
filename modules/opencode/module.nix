{inputs, ...}: {
  flake.modules.homeManager.opencode = {
    config,
    lib,
    options,
    ...
  }: {
    programs.opencode = {
      enable = lib.mkDefault true;
      # Pinned Stylix still selects its theme through the obsolete V1 setting.
      tui = lib.mkIf (options ? stylix.enable && config.stylix.enable) (lib.mkForce {});
      cli = {
        plugins = lib.mkIf config.programs.herdr.enable [
          "${config.xdg.configHome}/opencode/herdr-opencode"
        ];
        theme.name = lib.mkIf (options ? stylix.enable && config.stylix.enable) (lib.mkDefault "stylix");
      };
      context = ../../static/ai/AGENTS.md;
      commands = ../../static/ai/prompts;
      skills = inputs.its-skills + "/skills";
      settings.permissions = lib.mkDefault [
        {
          action = "question";
          resource = "*";
          effect = "deny";
        }
        {
          action = "websearch";
          resource = "*";
          effect = "allow";
        }
        {
          action = "webfetch";
          resource = "*";
          effect = "allow";
        }
      ];
    };
  };
}
