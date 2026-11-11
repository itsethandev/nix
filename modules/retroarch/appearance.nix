{
  flake.modules.homeManager.retroarch.programs.retroarch.settings = {
    menu_driver = "ozone";
    video_fullscreen = "true";
    # Avoid the EGL presentation wait observed when hidden on another workspace.
    video_driver = "vulkan";
    menu_use_preferred_system_color_theme = "false";
    # Ozone's built-in Gruvbox Dark palette.
    ozone_menu_color_theme = "3";
  };
}
