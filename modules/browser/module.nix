{inputs, ...}: {
  flake.modules.homeManager.browser = {
    config,
    lib,
    options,
    ...
  }: {
    imports = [inputs.zen-browser.homeModules.default];
    config =
      {
        programs.zen-browser = {
          enable = true;
          configPath = "${config.home.homeDirectory}/.zen";
          profiles."Default Profile" = {
            isDefault = true;
            path = "75qjbewr.Default Profile";
          };
        };
        xdg.mimeApps = {
          enable = true;
          defaultApplications = lib.genAttrs ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"] (_: ["zen-beta.desktop"]);
        };
      }
      // lib.optionalAttrs (options ? stylix.enable) {
        stylix.targets.zen-browser.profileNames = ["Default Profile"];
      };
  };
}
