-- Install packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Basic settings
vim.g.mapleader = ' '  -- Set leader key to space
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.colorcolumn = '80'

-- Plugin installation
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- Theme and UI
  use 'folke/tokyonight.nvim'
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' }
  }
  use {
    'akinsho/bufferline.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' }
  }
  use 'lukas-reineke/indent-blankline.nvim'

  -- File navigation
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' }
  }

  -- LSP and Completion
  use {
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets'
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,
}

  -- Git integration
  use 'lewis6991/gitsigns.nvim'
  use 'tpope/vim-fugitive'

  -- Terminal
  use 'akinsho/toggleterm.nvim'

  -- Quality of Life
  use 'windwp/nvim-autopairs'
  use 'tpope/vim-surround'
  use 'numToStr/Comment.nvim'
  use 'folke/which-key.nvim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Safe plugin loading and configuration
local function setup_plugins()
  -- Theme
  vim.cmd[[colorscheme tokyonight]]

  -- Status line
  local status_ok, lualine = pcall(require, 'lualine')
  if status_ok then
    lualine.setup()
  end

  -- Buffer line
  local status_ok, bufferline = pcall(require, 'bufferline')
  if status_ok then
    bufferline.setup()
  end

  -- Telescope
  local status_ok, telescope = pcall(require, 'telescope.builtin')
  if status_ok then
    vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
    vim.keymap.set('n', '<leader>fg', telescope.live_grep, {})
    vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
    vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})
  end

  -- NvimTree
  local status_ok, nvim_tree = pcall(require, 'nvim-tree')
  if status_ok then
    nvim_tree.setup()
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
  end

  -- LSP and Mason
  local status_ok, mason = pcall(require, 'mason')
  if status_ok then
    mason.setup()
    require('mason-lspconfig').setup({
      ensure_installed = { 'lua_ls', 'pyright', 'tsserver' }
    })
  end

  -- Completion
  local status_ok, cmp = pcall(require, 'cmp')
  if status_ok then
    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' }
      })
    })
  end

  -- Treesitter
  local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if status_ok then
    treesitter.setup({
        ensure_installed = { "lua" },  -- Start with just lua
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
    })
end

  -- Terminal
  local status_ok, toggleterm = pcall(require, 'toggleterm')
  if status_ok then
    toggleterm.setup({
      open_mapping = [[<C-\>]]
    })
  end

  -- Git signs
  local status_ok, gitsigns = pcall(require, 'gitsigns')
  if status_ok then
    gitsigns.setup()
  end

  -- Auto pairs
  local status_ok, autopairs = pcall(require, 'nvim-autopairs')
  if status_ok then
    autopairs.setup()
  end

  -- Comments
  local status_ok, comment = pcall(require, 'Comment')
  if status_ok then
    comment.setup()
  end

  -- Which key
  local status_ok, which_key = pcall(require, 'which-key')
  if status_ok then
    which_key.setup()
  end

  -- Indent lines
  local status_ok, indent_blankline = pcall(require, 'indent_blankline')
  if status_ok then
    indent_blankline.setup()
  end
end

-- Call setup function after a short delay to ensure plugins are loaded
vim.defer_fn(setup_plugins, 100)
