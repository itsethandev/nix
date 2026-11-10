{
  flake.modules.homeManager.retroarch = {
    programs.retroarch.cores.mesen.enable = true;

    xdg.configFile."retroarch/config/Mesen/Mesen.cfg".text = ''
      # 22 is RetroArch's Core Provided aspect ratio.
      aspect_ratio_index = "22"
      video_scale_integer = "true"
      video_smooth = "false"
      video_shader_enable = "false"
      rewind_enable = "true"
      run_ahead_enabled = "true"
      run_ahead_frames = "1"
    '';
  };
}
