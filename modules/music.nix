{
  home.turing = {
    config,
    lib,
    ...
  }: {
    programs.rmpc.enable = true;
    services = {
      easyeffects.enable = true;
      mpd = {
        enable = true;
        musicDirectory = lib.mkDefault "${config.home.homeDirectory}/Music";
        extraConfig = ''
          restore_paused "yes"
          audio_output {
            type "pulse"
            name "PipeWire Pulse"
            mixer_type "software"
          }
        '';
      };
      mpdris2.enable = true;
    };
  };
}
