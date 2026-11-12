# Agent tools

`modules.homeManager.agent-tools` installs shared CLI tools into the user environment on Linux and macOS. Includes Node.js, Bun, Python with Beautiful Soup, python-dateutil, PyYAML, Requests, and StrictYAML; Git and GitHub CLI; and search, web, data, document, and media tools. Linux also gets `wl-clipboard`.

Pi and OpenCode use the normal user `PATH`, without a development shell or launch alias. This module does not install either agent; select their modules separately.
