# File sharing

`modules.nixos.file-sharing` enables an authenticated, writable Samba share named `public`. Guest access, NetBIOS, and winbind are disabled; firewall ports stay closed.

Set `fileSharing.user` to an existing local account and provision its Samba credentials separately. The share defaults to that user's `Public` directory, created with mode 0750. Override `services.samba.settings.public.path` to share another directory.
