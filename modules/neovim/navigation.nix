{
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
    home.packages = [pkgs.ripgrep];
    programs.nixvim = {
      extraPackages = [pkgs.git];
      extraFiles."lua/files-highlight.lua".source = ../../static/neovim/files-highlight.lua;
      keymaps = lib.mkOrder 1001 [
        (keymap "<space>bd" "<Cmd>lua MiniBufremove.delete()<CR>" "Delete")
        (keymap "<space>bD" "<Cmd>lua MiniBufremove.delete(0, true)<CR>" "Delete!")
        (keymap "<space>ed" "<Cmd>lua MiniFiles.open()<CR>" "Directory")
        (keymap "<space>ef" "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>" "File directory")
        (keymap "<space>f/" ''<Cmd>Pick history scope="/"<CR>'' ''"/" history'')
        (keymap "<space>f:" ''<Cmd>Pick history scope=":"<CR>'' ''":" history'')
        (keymap "<space>fa" ''<Cmd>Pick git_hunks scope="staged"<CR>'' "Added hunks (all)")
        (keymap "<space>fA" ''<Cmd>Pick git_hunks path="%" scope="staged"<CR>'' "Added hunks (buf)")
        (keymap "<space>fb" "<Cmd>Pick buffers<CR>" "Buffers")
        (keymap "<space>fc" "<Cmd>Pick git_commits<CR>" "Commits (all)")
        (keymap "<space>fC" ''<Cmd>Pick git_commits path="%"<CR>'' "Commits (buf)")
        (keymap "<space>fd" ''<Cmd>Pick diagnostic scope="all"<CR>'' "Diagnostic workspace")
        (keymap "<space>fD" ''<Cmd>Pick diagnostic scope="current"<CR>'' "Diagnostic buffer")
        (keymap "<space>ff" "<Cmd>Pick files<CR>" "Files")
        (keymap "<space>fg" "<Cmd>Pick grep_live<CR>" "Grep live")
        (keymap "<space>fG" ''<Cmd>Pick grep pattern="<cword>"<CR>'' "Grep current word")
        (keymap "<space>fh" "<Cmd>Pick help<CR>" "Help tags")
        (keymap "<space>fH" "<Cmd>Pick hl_groups<CR>" "Highlight groups")
        (keymap "<space>fl" ''<Cmd>Pick buf_lines scope="all"<CR>'' "Lines (all)")
        (keymap "<space>fL" ''<Cmd>Pick buf_lines scope="current"<CR>'' "Lines (buf)")
        (keymap "<space>fm" "<Cmd>Pick git_hunks<CR>" "Modified hunks (all)")
        (keymap "<space>fM" ''<Cmd>Pick git_hunks path="%"<CR>'' "Modified hunks (buf)")
        (keymap "<space>fr" "<Cmd>Pick resume<CR>" "Resume")
        (keymap "<space>fv" ''<Cmd>Pick visit_paths cwd=""<CR>'' "Visit paths (all)")
        (keymap "<space>fV" "<Cmd>Pick visit_paths<CR>" "Visit paths (cwd)")
        (keymap "<space>ga" "<Cmd>Git diff --cached<CR>" "Added diff")
        (keymap "<space>gA" "<Cmd>Git diff --cached -- %<CR>" "Added diff buffer")
        (keymap "<space>gc" "<Cmd>Git commit<CR>" "Commit")
        (keymap "<space>gC" "<Cmd>Git commit --amend<CR>" "Commit amend")
        (keymap "<space>gd" "<Cmd>Git diff<CR>" "Diff")
        (keymap "<space>gD" "<Cmd>Git diff -- %<CR>" "Diff buffer")
        (keymap "<space>gl" "<Cmd>Git log --oneline --decorate --graph --all<CR>" "Log")
        (keymap "<space>gL" "<Cmd>Git log --oneline --decorate --graph --follow -- %<CR>" "Log buffer")
        (keymap "<space>go" "<Cmd>lua MiniDiff.toggle_overlay()<CR>" "Toggle overlay")
        (keymap "<space>gs" "<Cmd>lua MiniGit.show_at_cursor()<CR>" "Show at cursor")
        ((keymap "<space>gs" "<Cmd>lua MiniGit.show_at_cursor()<CR>" "Show at selection") // {mode = ["x"];})
      ];
      plugins.mini.modules = {
        bracketed.enable = lib.mkDefault true;
        bufremove.enable = lib.mkDefault true;
        diff.enable = lib.mkDefault true;
        extra.enable = lib.mkDefault true;
        files = {
          enable = lib.mkDefault true;
          content.highlight = lib.mkDefault {__raw = "require('files-highlight')";};
        };
        git.enable = lib.mkDefault true;
        pick.enable = lib.mkDefault true;
      };
    };
  };
}
