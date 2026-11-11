# Terminal

`modules.homeManager.terminal` enables Fish with vi bindings, a transient Starship prompt, fzf, zoxide, bat, and eza. Aliases replace `cat`, `cd`, `ls`, and related directory commands; changing directories automatically lists their contents.

bat is installed directly with its built-in `base16` theme, which uses the terminal palette. It does not use Home Manager's bat module or rebuild a highlighting cache during activation.

`modules.darwin.terminal` enables Fish as an allowed system shell. It does not change the user's login shell.
