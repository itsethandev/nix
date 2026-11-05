{inputs, ...}: {
  flake.modules.homeManager.pi = {
    lib,
    pkgs,
    ...
  }: {
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
        ];
        skills = [
          "${inputs.its-skills}/skills"
        ];
        subagents.disableBuiltins = lib.mkDefault true;
      };
    };

    home.file = {
      ".pi/agent/AGENTS.md".source = ../../static/ai/AGENTS.md;
      ".pi/agent/extensions/codex-speed.ts".source = ../../static/ai/pi/extensions/codex-speed.ts;
    };
  };
}
