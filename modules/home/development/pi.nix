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
    programs.pi-coding-agent = {
      enable = lib.mkDefault true;
      extraPackages = [pkgs.nodejs];
      keybindings = {
        "app.model.cycleForward" = lib.mkDefault [];
        "tui.select.down" = lib.mkDefault ["down" "ctrl+n"];
        "tui.select.up" = lib.mkDefault ["up" "ctrl+p"];
      };
      settings = {
        branchSummary.skipPrompt = lib.mkDefault true;
        defaultProvider = lib.mkDefault "openai-codex";
        defaultModel = lib.mkDefault "gpt-6.1-sol";
        defaultThinkingLevel = lib.mkDefault "medium";
        enabledModels = lib.mkDefault [
          "openai-codex/gpt-6.1-sol"
          "openai-codex/gpt-5.6-terra"
          "openai-codex/gpt-6-luna"
          "openai-codex/gpt-6-astra"
        ];
        packages = [
          "npm:pi-web-access"
          "npm:@narumitw/pi-stamp"
          "npm:@calesennett/pi-codex-fast"
        ];
        skills = [
          "${inputs.its-skills}/skills"
        ];
        subagents.disableBuiltins = lib.mkDefault true;
      };
    };

    home.file = {
      ".pi/agent/AGENTS.md".source = ../../../static/ai/AGENTS.md;
    };
  };
}
