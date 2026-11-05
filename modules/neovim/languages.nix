{
  flake.modules.homeManager.neovim = {
    config,
    lib,
    pkgs,
    ...
  }: let
    tsgo = config.programs.nixvim.plugins.lsp.servers.tsgo;
    keymap = key: action: desc: {
      inherit key action;
      mode = ["n"];
      options = {inherit desc;};
    };
  in {
    programs.nixvim = {
      autoCmd = lib.mkOrder 1001 [
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
      keymaps = lib.mkOrder 1002 [
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
      extraFiles."lua/typescript-command.lua".source = ../../static/neovim/typescript-command.lua;
      lsp.servers.tsgo.config = {
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
      plugins = {
        lsp = {
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
        treesitter = {
          enable = lib.mkDefault true;
          settings = {
            auto_install = lib.mkDefault true;
            highlight.enable = lib.mkDefault true;
            indent.enable = lib.mkDefault true;
          };
        };
      };
    };
  };
}
