{
  nixos.turing = {lib, ...}: let
    countryCode = "US";
    adapterMacAddress = "9C:04:B6:88:D5:B9";
    hotplugRestartRule = ''
      ACTION=="add|remove", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", \
      RUN+="/run/current-system/systemd/bin/systemctl try-restart wpa_supplicant.service"
    '';
  in {
    options = {
      # NetworkManager handles device hotplug over D-Bus. The upstream restart rule
      # stops its shared supplicant on dongle insertion and disconnects home Wi-Fi.
      # Fail on upstream changes so this workaround cannot silently become obsolete.
      services.udev.extraRules = lib.mkOption {
        apply = rules:
          if lib.hasInfix hotplugRestartRule rules
          then lib.replaceStrings [hotplugRestartRule] [""] rules
          else throw "steam-frame: upstream wpa_supplicant hotplug rule changed; reassess the restart workaround.";
      };
    };

    config = {
      # The world regulatory domain disables the dongle's 6 GHz link. Setting only
      # wpa_supplicant's country did not set the global kernel domain on turing.
      boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=${countryCode}";

      hardware.steam-hardware.enable = lib.mkDefault true;
      networking = {
        networkmanager = {
          enable = lib.mkDefault true;
          wifi.backend = lib.mkDefault "wpa_supplicant";
          # Ordinary Wi-Fi profiles must not autoconnect through the Frame dongle.
          # NetworkManager requires escaped spaces in allowed-connections IDs.
          settings."device-steam-frame" = {
            "match-device" = "mac:${adapterMacAddress}";
            "allowed-connections" = "id:Steam\\sFrame\\sWireless\\sAdapter";
          };
        };
        wireless.extraConfig = "country=${countryCode}";
      };
      programs.steam = {
        enable = lib.mkDefault true;
        remotePlay.openFirewall = lib.mkDefault true;
      };
    };
  };
}
