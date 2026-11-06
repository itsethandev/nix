{
  flake.modules.homeManager.neovim = {lib, ...}: let
    keymap = key: action: desc: {
      inherit key action;
      mode = ["n"];
      options = {inherit desc;};
    };
  in {
    programs.nixvim = {
      keymaps = lib.mkOrder 1003 [
        (keymap "<space>mf" "<Cmd>lua MiniMap.toggle_focus()<CR>" "Focus (toggle)")
        (keymap "<space>mr" "<Cmd>lua MiniMap.refresh()<CR>" "Refresh")
        (keymap "<space>ms" "<Cmd>lua MiniMap.toggle_side()<CR>" "Side (toggle)")
        (keymap "<space>mt" "<Cmd>lua MiniMap.toggle()<CR>" "Toggle")
      ];
      plugins = {
        lualine = {
          enable = lib.mkDefault true;
          settings.sections.lualine_x = lib.mkDefault ["%S"];
        };
        mini.modules = {
          clue = {
            # Nixvim's unkeyed attrs merge across role files and render as Lua list entries.
            clues = lib.mkDefault {
              __unkeyed-06-map = {
                mode = "n";
                keys = "<Leader>m";
                desc = "+Map";
              };
              __unkeyed-07-ui = {
                mode = "n";
                keys = "<Leader>u";
                desc = "+UI";
              };
              __unkeyed-08-zettelkasten = {
                mode = "n";
                keys = "<Leader>z";
                desc = "+Zettelkasten";
              };
              __unkeyed-11-completion.__raw = "require('mini.clue').gen_clues.builtin_completion()";
              __unkeyed-12-g.__raw = "require('mini.clue').gen_clues.g()";
              __unkeyed-13-marks.__raw = "require('mini.clue').gen_clues.marks()";
              __unkeyed-14-registers.__raw = "require('mini.clue').gen_clues.registers()";
              __unkeyed-15-brackets.__raw = "require('mini.clue').gen_clues.square_brackets()";
              __unkeyed-16-windows.__raw = "require('mini.clue').gen_clues.windows({ submode_resize = true })";
              __unkeyed-17-z.__raw = "require('mini.clue').gen_clues.z()";
            };
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
          icons.enable = lib.mkDefault true;
          map.enable = lib.mkDefault true;
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
        };
        noice = {
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
        toggleterm = {
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
      };
    };
  };
}
