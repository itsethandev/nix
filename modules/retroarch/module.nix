{
  flake.modules.homeManager.retroarch = {config, ...}: {
    programs.retroarch = {
      enable = true;
      settings = {
        rgui_browser_directory = "${config.home.homeDirectory}/Games/roms";
        system_directory = "${config.home.homeDirectory}/Games/bios";
      };
    };
  };
}
