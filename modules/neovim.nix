{inputs, ...}: let
  editor = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (config.lib.nixvim) mkRaw;
    projectFormatters = mkRaw ''require("project-formatters").formatters'';
    tsgo = config.programs.nixvim.plugins.lsp.servers.tsgo;
    keymap = key: action: desc: {
      inherit key action;
      mode = ["n"];
      options = {inherit desc;};
    };
  in {
    imports = [
      inputs.nixvim.homeModules.nixvim
      {
        programs.nixvim.autoCmd = [
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
          {
            event = "FileType";
            pattern = "markdown";
            desc = "Keep Markdown wrapping visual only";
            command = "setlocal textwidth=0";
          }
          {
            event = "FileType";
            pattern = ["json" "jsonc"];
            desc = "Show JSON quotes";
            command = "setlocal conceallevel=0";
          }
          {
            event = "FileType";
            pattern = ["javascript" "javascriptreact" "typescript" "typescriptreact"];
            desc = "Add JS/TS console.log helper";
            command = ''
              lua vim.keymap.set("n", "<leader>cl", function()
                local name = vim.fn.expand("<cword>")
                if name == nil or name == "" then
                  return
                end

                local indent = string.rep(" ", vim.fn.indent("."))
                local line = indent .. 'console.log("' .. name .. '", ' .. name .. ');'
                vim.api.nvim_put({ line }, "l", true, true)
              end, { buffer = true, desc = "Insert console.log for symbol" })
            '';
          }
        ];
      }
      {
        imports = [
          {
            programs.nixvim.keymaps = [
              (keymap "<space>bd" "<Cmd>lua MiniBufremove.delete()<CR>" "Delete")
              (keymap "<space>bD" "<Cmd>lua MiniBufremove.delete(0, true)<CR>" "Delete!")
            ];
          }
          {
            programs.nixvim.keymaps = [
              (keymap "<space>ed" "<Cmd>lua MiniFiles.open()<CR>" "Directory")
              (keymap "<space>ef" "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>" "File directory")
            ];
          }
          {
            programs.nixvim.keymaps = [
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
            ];
          }
          {
            programs.nixvim.keymaps = [
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
          }
          {
            programs.nixvim.keymaps = [
              (keymap "<space>la" "<Cmd>lua vim.lsp.buf.code_action()<CR>" "Actions")
              (keymap "<space>ld" "<Cmd>lua vim.diagnostic.open_float()<CR>" "Diagnostic popup")
              (keymap "<space>lf" ''<Cmd>lua require("conform").format()<CR>'' "Format")
              (keymap "<space>li" "<Cmd>lua vim.lsp.buf.implementation()<CR>" "Implementation")
              (keymap "<space>lh" "<Cmd>lua vim.lsp.buf.hover()<CR>" "Hover")
              (keymap "<space>ll" "<Cmd>lua vim.lsp.codelens.run()<CR>" "Lens")
              (keymap "<space>lr" "<Cmd>lua vim.lsp.buf.rename()<CR>" "Rename")
              (keymap "<space>lR" "<Cmd>lua vim.lsp.buf.references()<CR>" "References")
              (keymap "<space>ls" "<Cmd>lua vim.lsp.buf.definition()<CR>" "Source definition")
              (keymap "<space>lt" "<Cmd>lua vim.lsp.buf.type_definition()<CR>" "Type definition")
            ];
          }
          {
            programs.nixvim.keymaps = [
              (keymap "<space>mf" "<Cmd>lua MiniMap.toggle_focus()<CR>" "Focus (toggle)")
              (keymap "<space>mr" "<Cmd>lua MiniMap.refresh()<CR>" "Refresh")
              (keymap "<space>ms" "<Cmd>lua MiniMap.toggle_side()<CR>" "Side (toggle)")
              (keymap "<space>mt" "<Cmd>lua MiniMap.toggle()<CR>" "Toggle")
            ];
          }
        ];
        programs.nixvim.keymaps = [
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
      }
      {
        programs.nixvim.opts = lib.mapAttrs (_: lib.mkDefault) {
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
      }
      {
        imports = [
          {
            programs.nixvim = {
              globals.autoformat = lib.mkDefault true;
              extraFiles = {
                "lua/project-formatters.lua".source = ../static/neovim/project-formatters.lua;
                "oxfmt-default.json".text = "{}";
              };
              extraPackagesAfter = with pkgs; [alejandra biome black oxfmt prettier rustfmt];
              keymaps = [
                {
                  key = "<leader>uf";
                  mode = "n";
                  action = mkRaw ''
                    function()
                      vim.g.autoformat = not vim.g.autoformat
                      vim.notify("Auto Format (Global): " .. (vim.g.autoformat and "On" or "Off"))
                    end
                  '';
                  options = {
                    desc = "Toggle Auto Format (Global)";
                    silent = true;
                  };
                }
                {
                  key = "<leader>uF";
                  mode = "n";
                  action = mkRaw ''
                    function()
                      local enabled = vim.b.autoformat
                      if enabled == nil then
                        enabled = vim.g.autoformat ~= false
                      end
                      vim.b.autoformat = not enabled
                      vim.notify("Auto Format (Buffer): " .. (vim.b.autoformat and "On" or "Off"))
                    end
                  '';
                  options = {
                    desc = "Toggle Auto Format (Buffer)";
                    silent = true;
                  };
                }
              ];
              plugins.conform-nvim = {
                autoInstall.enable = lib.mkDefault false;
                enable = lib.mkDefault true;
                settings = {
                  default_format_opts = {
                    lsp_format = lib.mkDefault "fallback";
                    timeout_ms = lib.mkDefault 2000;
                    stop_after_first = lib.mkDefault true;
                  };
                  formatters = {
                    oxfmt = lib.mkDefault (mkRaw ''require("project-formatters").override("oxfmt")'');
                    prettier = lib.mkDefault (mkRaw ''require("project-formatters").override("prettier")'');
                    biome = lib.mkDefault (mkRaw ''require("project-formatters").override("biome")'');
                    rustfmt.cwd = lib.mkDefault (mkRaw ''function(_, ctx) return ctx.dirname end'');
                    project_formatter_error = lib.mkDefault (mkRaw ''require("project-formatters").blocked'');
                  };
                  format_on_save = lib.mkDefault (mkRaw ''
                    function(bufnr)
                      if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
                        return
                      end

                      return {}
                    end
                  '');
                  formatters_by_ft = lib.mapAttrs (_: lib.mkDefault) {
                    css = projectFormatters;
                    html = projectFormatters;
                    javascript = projectFormatters;
                    javascriptreact = projectFormatters;
                    json = projectFormatters;
                    jsonc = projectFormatters;
                    nix = ["alejandra"];
                    python = ["black"];
                    rust = ["rustfmt"];
                    typescript = projectFormatters;
                    typescriptreact = projectFormatters;
                  };
                  notify_on_error = lib.mkDefault true;
                  notify_no_formatters = lib.mkDefault false;
                };
              };
            };
          }
          {
            programs.nixvim.extraFiles."lua/typescript-command.lua".source = ../static/neovim/typescript-command.lua;
            programs.nixvim.lsp.servers.tsgo.config = {
              root_dir = lib.mkDefault {__raw = ''require("typescript-command")(nil).root_dir'';};
              cmd = lib.mkIf (tsgo.cmd == null) (lib.mkDefault {
                __raw = ''
                  require("typescript-command")(${
                    if tsgo.package == null
                    then "nil"
                    else builtins.toJSON (lib.getExe tsgo.package)
                  }).cmd
                '';
              });
            };
            programs.nixvim.plugins.lsp = {
              enable = lib.mkDefault true;
              servers = {
                cssls = {
                  enable = lib.mkDefault true;
                  packageFallback = lib.mkDefault true;
                };
                nixd = {
                  enable = lib.mkDefault true;
                  packageFallback = lib.mkDefault true;
                  settings.nixpkgs.expr = lib.mkDefault "import ${pkgs.path} { }";
                };
                basedpyright = {
                  enable = lib.mkDefault true;
                  packageFallback = lib.mkDefault true;
                };
                rust_analyzer = {
                  enable = lib.mkDefault true;
                  packageFallback = lib.mkDefault true;
                  installRustc = lib.mkDefault false;
                  installCargo = lib.mkDefault false;
                  settings.cargo.targetDir = lib.mkDefault "target/rust-analyzer";
                };
                tailwindcss = {
                  enable = lib.mkDefault true;
                  packageFallback = lib.mkDefault true;
                };
                tsgo = {
                  enable = lib.mkDefault true;
                  package = lib.mkDefault pkgs.typescript;
                  packageFallback = lib.mkDefault true;
                  cmd = lib.mkDefault null;
                };
              };
            };
          }
          {
            programs.nixvim.plugins.lualine = {
              enable = lib.mkDefault true;
              settings.sections.lualine_x = lib.mkDefault ["%S"];
            };
          }
          {
            home.packages = [pkgs.ripgrep];
            programs.nixvim.extraPackages = [pkgs.git];
            programs.nixvim.extraFiles."lua/files-highlight.lua".source = ../static/neovim/files-highlight.lua;
            programs.nixvim.plugins.mini = {
              enable = lib.mkDefault true;
              mockDevIcons = lib.mkDefault true;
              modules = {
                ai.enable = lib.mkDefault true;
                basics.enable = lib.mkDefault true;
                bracketed.enable = lib.mkDefault true;
                bufremove.enable = lib.mkDefault true;
                clue = {
                  clues = lib.mkDefault [
                    {
                      mode = "n";
                      keys = "<Leader>b";
                      desc = "+Buffer";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>e";
                      desc = "+Explore/Edit";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>f";
                      desc = "+Find";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>g";
                      desc = "+Git";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>l";
                      desc = "+Language";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>m";
                      desc = "+Map";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>u";
                      desc = "+UI";
                    }
                    {
                      mode = "n";
                      keys = "<Leader>z";
                      desc = "+Zettelkasten";
                    }
                    {
                      mode = "x";
                      keys = "<Leader>g";
                      desc = "+Git";
                    }
                    {
                      mode = "x";
                      keys = "<Leader>l";
                      desc = "+Language";
                    }
                    {__raw = "require('mini.clue').gen_clues.builtin_completion()";}
                    {__raw = "require('mini.clue').gen_clues.g()";}
                    {__raw = "require('mini.clue').gen_clues.marks()";}
                    {__raw = "require('mini.clue').gen_clues.registers()";}
                    {__raw = "require('mini.clue').gen_clues.square_brackets()";}
                    {__raw = "require('mini.clue').gen_clues.windows({ submode_resize = true })";}
                    {__raw = "require('mini.clue').gen_clues.z()";}
                  ];
                  triggers = lib.mkDefault [
                    {
                      mode = ["n" "x"];
                      keys = "<Leader>";
                    }
                    {
                      mode = "n";
                      keys = "\\";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "[";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "]";
                    }
                    {
                      mode = "i";
                      keys = "<C-x>";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "g";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "'";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "`";
                    }
                    {
                      mode = ["n" "x"];
                      keys = ''"'';
                    }
                    {
                      mode = ["i" "c"];
                      keys = "<C-r>";
                    }
                    {
                      mode = "n";
                      keys = "<C-w>";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "s";
                    }
                    {
                      mode = ["n" "x"];
                      keys = "z";
                    }
                  ];
                };
                cmdline.enable = lib.mkDefault true;
                comment.enable = lib.mkDefault true;
                completion.enable = lib.mkDefault true;
                cursorword.enable = lib.mkDefault true;
                diff.enable = lib.mkDefault true;
                extra.enable = lib.mkDefault true;
                files = {
                  enable = lib.mkDefault true;
                  content.highlight = lib.mkDefault {__raw = "require('files-highlight')";};
                };
                git.enable = lib.mkDefault true;
                hipatterns.enable = lib.mkDefault true;
                icons.enable = lib.mkDefault true;
                indentscope.enable = lib.mkDefault true;
                map.enable = lib.mkDefault true;
                move.enable = lib.mkDefault true;
                pairs.enable = lib.mkDefault true;
                pick.enable = lib.mkDefault true;
                snippets.enable = lib.mkDefault true;
                splitjoin.enable = lib.mkDefault true;
                starter = {
                  enable = lib.mkDefault true;
                  header = lib.mkDefault ''
                    ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
                    ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
                    ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
                    ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
                    ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
                  '';
                  footer = lib.mkDefault "";
                };
                surround.enable = lib.mkDefault true;
                trailspace.enable = lib.mkDefault true;
              };
            };
          }
          {
            programs.nixvim.plugins.noice = {
              enable = lib.mkDefault true;
              settings = {
                lsp.override = {
                  "vim.lsp.util.convert_input_to_markdown_lines" = lib.mkDefault true;
                  "vim.lsp.util.stylize_markdown" = lib.mkDefault true;
                  "cmp.entry.get_documentation" = lib.mkDefault true;
                };
                routes = lib.mkDefault [
                  {
                    filter = {
                      event = "msg_show";
                      any = [{find = "%d+L, %d+B";} {find = "; after #%d+";} {find = "; before #%d+";}];
                    };
                    view = "mini";
                  }
                ];
                presets = {
                  bottom_search = lib.mkDefault true;
                  command_palette = lib.mkDefault true;
                  long_message_to_split = lib.mkDefault true;
                };
              };
            };
          }
          {
            programs.nixvim.plugins.toggleterm = {
              enable = lib.mkDefault true;
              settings = {
                direction = lib.mkDefault "float";
                open_mapping = lib.mkDefault "[[<C-/>]]";
                insert_mappings = lib.mkDefault true;
                terminal_mappings = lib.mkDefault true;
                start_in_insert = lib.mkDefault true;
                shade_terminals = lib.mkDefault true;
                float_opts.border = lib.mkDefault "curved";
              };
            };
          }
          {
            programs.nixvim.plugins.treesitter = {
              enable = lib.mkDefault true;
              settings = {
                auto_install = lib.mkDefault true;
                highlight.enable = lib.mkDefault true;
                indent.enable = lib.mkDefault true;
              };
            };
          }
        ];
      }
    ];
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
    };
  };
in {
  flake.modules.homeManager.neovim = {
    lib,
    pkgs,
    ...
  }: {
    imports = [editor];
    xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;
      defaultApplications = lib.genAttrs ["text/plain" "text/markdown" "application/json" "application/x-shellscript"] (_: ["nvim.desktop"]);
    };
  };
}
