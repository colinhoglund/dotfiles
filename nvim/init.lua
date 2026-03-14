vim.g.mapleader = " "
vim.g.loaded_netrw            = 1
vim.g.loaded_netrwPlugin      = 1
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Options
vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.cursorline     = true
vim.opt.hlsearch       = true
vim.opt.incsearch      = true
vim.opt.backspace      = "indent,eol,start"
vim.opt.tabstop        = 2
vim.opt.softtabstop    = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.foldmethod     = "indent"
vim.opt.foldlevelstart = 10
vim.opt.foldnestmax    = 10
vim.opt.splitbelow     = true
vim.opt.splitright     = true

-- Keymaps
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics" })
vim.keymap.set("n", "j",         "gj")
vim.keymap.set("n", "k",         "gk")
vim.keymap.set("n", "<C-H>",     "<C-W><C-H>")
vim.keymap.set("n", "<C-J>",     "<C-W><C-J>")
vim.keymap.set("n", "<C-K>",     "<C-W><C-K>")
vim.keymap.set("n", "<C-L>",     "<C-W><C-L>")

-- Enable treesitter highlighting and indent for any filetype with an installed parser
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if pcall(vim.treesitter.start) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern  = "*.star",
  callback = function(ev) vim.bo[ev.buf].filetype = "python" end,
})

-- LSP keymaps (set per-buffer when a server attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(key, fn, desc)
      vim.keymap.set("n", key, fn, { buffer = ev.buf, desc = desc })
    end
    map("gd",         vim.lsp.buf.definition,      "Go to definition")
    map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
    map("gi",         vim.lsp.buf.implementation,  "Go to implementation")
    map("gr",         vim.lsp.buf.references,      "References")
    map("K",          vim.lsp.buf.hover,           "Hover docs")
    map("<leader>D",  vim.lsp.buf.type_definition, "Type definition")
    map("<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action,     "Code action")
  end,
})

require("lazy").setup({

  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    config   = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install({
        "bash", "go", "hcl", "json", "lua",
        "markdown", "python", "toml", "yaml",
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "catppuccin/nvim" },
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin-mocha" } })
    end,
  },

  {
    "williamboman/mason.nvim",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "pyright", "terraformls", "lua_ls" },
      })
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      vim.lsp.enable({ "gopls", "pyright", "terraformls", "lua_ls" })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event        = "InsertEnter",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config       = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        }),
        sources = { { name = "nvim_lsp" } },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff",  function() require("telescope.builtin").find_files() end,                desc = "Find files" },
      { "<leader>fg",  function() require("telescope.builtin").live_grep() end,                 desc = "Live grep" },
      { "<leader>fb",  function() require("telescope.builtin").buffers() end,                   desc = "Find buffers" },
      { "<leader>fo",  function() require("telescope.builtin").oldfiles() end,                  desc = "Recent files" },
      { "<leader>fz",  function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Fuzzy find in buffer" },
      { "<leader>fd",  function() require("telescope.builtin").diagnostics() end,               desc = "Diagnostics" },
      { "<leader>fr",  function() require("telescope.builtin").lsp_references() end,            desc = "LSP references" },
      { "<leader>fs",  function() require("telescope.builtin").lsp_document_symbols() end,      desc = "Document symbols" },
      { "<leader>fc",  function() require("telescope.builtin").git_commits() end,               desc = "Git commits" },
      { "<leader>fgb", function() require("telescope.builtin").git_branches() end,              desc = "Git branches" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config   = { preview_width = 0.55 },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },

  {
    "stevearc/conform.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("conform").setup({
        format_on_save   = { timeout_ms = 500, lsp_fallback = true },
        formatters_by_ft = {
          go        = { "gofmt", "goimports" },
          python    = { "ruff_format" },
          terraform = { "terraform_fmt" },
          json      = { "jq" },
          lua       = { "stylua" },
          ["*"]     = { "trim_whitespace" },
        },
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event  = { "BufReadPost", "BufWritePost" },
    config = function()
      require("lint").linters_by_ft = {
        go     = { "golangcilint" },
        python = { "ruff" },
      }
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    keys   = { { "<leader>t", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" } },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event  = "BufReadPost",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs  = package.loaded.gitsigns
          local map = function(key, fn, desc)
            vim.keymap.set("n", key, fn, { buffer = bufnr, desc = desc })
          end
          map("]c",         gs.next_hunk,    "Next hunk")
          map("[c",         gs.prev_hunk,    "Prev hunk")
          map("<leader>hp", gs.preview_hunk, "Preview hunk")
          map("<leader>hs", gs.stage_hunk,   "Stage hunk")
          map("<leader>hr", gs.reset_hunk,   "Reset hunk")
          map("<leader>hb", gs.blame_line,   "Blame line")
        end,
      })
    end,
  },

  { "tpope/vim-fugitive",   cmd   = "Git" },
  { "tpope/vim-surround",   event = "BufReadPost" },
  { "tpope/vim-repeat",     event = "BufReadPost" },
  { "tpope/vim-unimpaired", event = "BufReadPost" },

}, { rocks = { enabled = false }, ui = { border = "rounded" } })
