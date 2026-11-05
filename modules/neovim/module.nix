{inputs, ...}: {
  flake.modules.homeManager.neovim = {
    lib,
    pkgs,
    ...
  }: let
    keymap = key: action: desc: {
      inherit key action;
      mode = ["n"];
      options = {inherit desc;};
    };
  in {
    imports = [inputs.nixvim.homeModules.nixvim];
    programs.nixvim = {
      enable = lib.mkDefault true;
      globals = {
        mapleader = lib.mkDefault " ";
        maplocalleader = lib.mkDefault "\\";
      };
      defaultEditor = lib.mkDefault true;
      nixpkgs.useGlobalPackages = lib.mkDefault true;
      viAlias = lib.mkDefault true;
      vimAlias = lib.mkDefault true;
      autoCmd = lib.mkOrder 1000 [
        {
          event = "TextYankPost";
          desc = "Highlight when yanking text";
          command = "lua vim.highlight.on_yank()";
        }
        {
          event = ["FocusGained" "BufEnter" "CursorHold" "CursorHoldI"];
          desc = "Reload files changed outside Neovim";
          command = "if mode() != 'c' | checktime | endif";
        }
        {
          event = "FileChangedShellPost";
          desc = "Notify after reloading changed file";
          command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None";
        }
      ];
      # Keep core mappings ahead of feature mappings, independent of file import order.
      keymaps = lib.mkOrder 1000 [
        {
          action = "v:count == 0 ? 'gj' : 'j'";
          key = "j";
          mode = ["n" "x"];
          options = {
            desc = "Down";
            expr = true;
            silent = true;
          };
        }
        {
          action = "v:count == 0 ? 'gk' : 'k'";
          key = "k";
          mode = ["n" "x"];
          options = {
            desc = "Up";
            expr = true;
            silent = true;
          };
        }
        {
          action = "<cmd>nohlsearch<CR>";
          key = "<Esc>";
          mode = ["n"];
          options = {
            desc = "clear search highlight";
            silent = true;
          };
        }
        {
          action = "<gv";
          key = "<";
          mode = "x";
          options.silent = true;
        }
        {
          action = ">gv";
          key = ">";
          mode = "x";
          options.silent = true;
        }
        (keymap "<C-h>" "<C-w>h" "Left window")
        (keymap "<C-j>" "<C-w>j" "Lower window")
        (keymap "<C-k>" "<C-w>k" "Upper window")
        (keymap "<C-l>" "<C-w>l" "Right window")
      ];
      opts = lib.mapAttrs (_: lib.mkDefault) {
        autoindent = true;
        autoread = true;
        breakindent = true;
        clipboard = "unnamedplus";
        conceallevel = 0;
        cursorline = true;
        cursorlineopt = "number";
        expandtab = true;
        exrc = true;
        fillchars = lib.mapAttrs (_: lib.mkDefault) {
          foldopen = "";
          foldclose = "";
          fold = " ";
          foldsep = " ";
          diff = "╱";
          eob = " ";
        };
        foldlevel = 99;
        foldmethod = "indent";
        foldtext = "";
        inccommand = "split";
        ignorecase = true;
        iskeyword = "@,48-57,_,192-255,-";
        linebreak = true;
        wrap = true;
        laststatus = 3;
        list = true;
        listchars = lib.mapAttrs (_: lib.mkDefault) {
          tab = "» ";
          trail = "·";
          nbsp = "␣";
        };
        number = true;
        numberwidth = 2;
        pumblend = 10;
        pumheight = 10;
        relativenumber = true;
        ruler = false;
        scrolloff = 8;
        shiftround = true;
        shiftwidth = 2;
        showcmd = true;
        showcmdloc = "statusline";
        showmode = false;
        smartindent = true;
        softtabstop = 2;
        signcolumn = "yes";
        smartcase = true;
        splitbelow = true;
        splitright = true;
        switchbuf = "usetab";
        tabstop = 2;
        termguicolors = true;
        textwidth = 80;
        timeoutlen = 400;
        undofile = true;
      };
      plugins.mini = {
        enable = lib.mkDefault true;
        mockDevIcons = lib.mkDefault true;
        modules = {
          ai.enable = lib.mkDefault true;
          basics.enable = lib.mkDefault true;
          comment.enable = lib.mkDefault true;
          completion.enable = lib.mkDefault true;
          cursorword.enable = lib.mkDefault true;
          hipatterns.enable = lib.mkDefault true;
          indentscope.enable = lib.mkDefault true;
          move.enable = lib.mkDefault true;
          pairs.enable = lib.mkDefault true;
          snippets.enable = lib.mkDefault true;
          splitjoin.enable = lib.mkDefault true;
          surround.enable = lib.mkDefault true;
          trailspace.enable = lib.mkDefault true;
        };
      };
    };
    xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;
      defaultApplications = lib.genAttrs ["text/plain" "text/markdown" "application/json" "application/x-shellscript"] (_: ["nvim.desktop"]);
    };
  };
}
