{
  flake.modules.homeManager.retroarch = {
    config,
    lib,
    ...
  }: {
    programs.retroarch = {
      enable = true;
      cores.mesen.enable = true;
      settings = {
        rgui_browser_directory = "${config.home.homeDirectory}/Games/roms";
        system_directory = "${config.home.homeDirectory}/Games/bios";
        savefile_directory = "${config.home.homeDirectory}/Games/saves";
        savestate_directory = "${config.home.homeDirectory}/Games/states";
        fastforward_ratio = "3.0";
        autosave_interval = "10";
        savestate_auto_save = "true";
        savestate_auto_load = "true";
      };
    };
    home.activation.retroarchSaveDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p -- ${lib.escapeShellArgs (with config.programs.retroarch.settings; [savefile_directory savestate_directory])}
    '';
  };
}
