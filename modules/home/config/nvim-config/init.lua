vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.updatetime = 200
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.list = true
opt.listchars = { tab = "  ", trail = ".", nbsp = "+" }

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = ">" },
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map("n", "<leader>w", "<cmd>w<cr>", "Save")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")
map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", "Explorer")
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", "Buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", "Help")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Close buffer")
map("n", "<leader>bn", "<cmd>bnext<cr>", "Next buffer")
map("n", "<leader>bp", "<cmd>bprevious<cr>", "Previous buffer")
map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, "Format")

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = false,
  integrations = {
    cmp = true,
    gitsigns = true,
    native_lsp = { enabled = true },
    neo_tree = true,
    notify = true,
    telescope = true,
    treesitter = true,
    which_key = true,
  },
})
vim.cmd.colorscheme("catppuccin")

require("lualine").setup({
  options = {
    theme = "catppuccin",
    component_separators = "",
    section_separators = "",
    globalstatus = true,
  },
})

require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    separator_style = "thin",
    show_buffer_close_icons = false,
    show_close_icon = false,
  },
})

require("gitsigns").setup()
require("Comment").setup()
require("nvim-autopairs").setup()
require("which-key").setup()
require("ibl").setup()

require("notify").setup({
  background_colour = "#1e1e2e",
  stages = "fade_in_slide_out",
})

require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
  },
})

require("neo-tree").setup({
  close_if_last_window = true,
  enable_git_status = true,
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
  window = {
    width = 32,
    mappings = {
      ["<space>"] = "none",
    },
  },
})

require("telescope").setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "top",
      width = 0.9,
      height = 0.82,
    },
    sorting_strategy = "ascending",
    winblend = 0,
  },
})

require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
})

local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  }),
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

local servers = {
  bashls = {},
  marksman = {},
  nil_ls = {
    settings = {
      ["nil"] = {
        formatting = { command = { "nixfmt" } },
      },
    },
  },
  pyright = {},
  texlab = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Definition" }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Declaration" }))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
  end,
})
