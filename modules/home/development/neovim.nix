{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bash-language-server
    fd
    lua-language-server
    marksman
    nil
    nixfmt-rfc-style
    pyright
    ripgrep
    stylua
    texlab
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      bufferline-nvim
      catppuccin-nvim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      comment-nvim
      friendly-snippets
      gitsigns-nvim
      indent-blankline-nvim
      lualine-nvim
      luasnip
      neo-tree-nvim
      noice-nvim
      nui-nvim
      nvim-autopairs
      nvim-cmp
      nvim-lspconfig
      nvim-notify
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      which-key-nvim
    ];
  };

  xdg.configFile."nvim/init.lua".source = ../config/nvim-config/init.lua;
}
