# Steam Frame

`modules.nixos.steam-frame` configures a dedicated wireless adapter for Steam Frame. Set `steamFrame.countryCode` and `steamFrame.adapterMacAddress`.

It enables NetworkManager with wpa_supplicant, Steam hardware support, and Steam Remote Play firewall rules. The adapter is restricted to the Steam Frame connection profile, and the regulatory country is set for the kernel and supplicant.

Adapter hotplug does not restart the shared supplicant, avoiding disruption to other Wi-Fi connections.
