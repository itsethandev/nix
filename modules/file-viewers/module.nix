{
  flake.modules.homeManager.file-viewers = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [celluloid loupe papers];
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        {"application/pdf" = ["org.gnome.Papers.desktop"];}
        // lib.genAttrs ["image/apng" "image/avif" "image/bmp" "image/gif" "image/heic" "image/jpeg" "image/jxl" "image/png" "image/svg+xml" "image/tiff" "image/webp"] (_: ["org.gnome.Loupe.desktop"])
        // lib.genAttrs ["audio/aac" "audio/flac" "audio/m4a" "audio/mpeg" "audio/ogg" "audio/opus" "audio/wav" "audio/webm" "video/mp4" "video/mpeg" "video/ogg" "video/quicktime" "video/webm" "video/x-matroska" "video/x-msvideo"] (_: ["io.github.celluloid_player.Celluloid.desktop"]);
    };
  };
}
