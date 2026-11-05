{lib, ...}: {
  home = lib.genAttrs ["turing" "newton"] (host: {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.discord] ++ lib.optionals (host == "turing") (with pkgs; [celluloid loupe papers]);
    programs.btop.enable = host == "turing";
    wayland.windowManager.hyprland.settings.window_rule = lib.mkIf (host == "turing" && config.wayland.windowManager.hyprland.enable) (lib.mkOrder 1501 [
      {
        name = "discord-popout";
        match.initial_title = "^Discord Popout$";
        float = true;
        pin = true;
        size = "(monitor_w*0.25) (monitor_h*0.25)";
        move = "(monitor_w-window_w-48) (monitor_h-window_h-48)";
      }
    ]);
    xdg.mimeApps = lib.mkIf (host == "turing") {
      enable = true;
      defaultApplications =
        {"application/pdf" = ["org.gnome.Papers.desktop"];}
        // lib.genAttrs ["image/apng" "image/avif" "image/bmp" "image/gif" "image/heic" "image/jpeg" "image/jxl" "image/png" "image/svg+xml" "image/tiff" "image/webp"] (_: ["org.gnome.Loupe.desktop"])
        // lib.genAttrs ["audio/aac" "audio/flac" "audio/m4a" "audio/mpeg" "audio/ogg" "audio/opus" "audio/wav" "audio/webm" "video/mp4" "video/mpeg" "video/ogg" "video/quicktime" "video/webm" "video/x-matroska" "video/x-msvideo"] (_: ["io.github.celluloid_player.Celluloid.desktop"]);
    };
  });
}
