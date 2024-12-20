require('devpabs')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope.nvim', tag = '0.1.8'},
    {'rose-pine/neovim'},
    {'nvim-treesitter/nvim-treesitter'},
    {'mbbill/undotree'},
    {'tpope/vim-fugitive'},

    -- Mason for managing LSP servers
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},

    -- LSP setup
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'L3MON4D3/LuaSnip'},
    {'github/copilot.vim'},
    {'theprimeagen/harpoon', branch = 'harpoon2'},
    {'theprimeagen/vim-be-good'},
    {'wellle/context.vim'},
    {
     "ray-x/lsp_signature.nvim",
      event = "InsertEnter",
      opts = {
        bind = true,
        handler_opts = {
          border = "rounded"
        }
      },
      config = function(_, opts) require'lsp_signature'.setup(opts) end
    },

    -- Ensure Ruff-LSP is installed and setup
    {'jose-elias-alvarez/null-ls.nvim'},
    {'hiphish/rainbow-delimiters.nvim'},
})


-- Set up LSP diagnostics handler
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = false,  -- Update diagnostics only after leaving insert mode
    severity_sort = true,      -- Sort diagnostics by severity
  }
)

vim.lsp.set_log_level("OFF")

-- Enable folding with Treesitter
vim.o.foldmethod = 'expr'                -- Use expression-based folding
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'  -- Use Treesitter's fold expression
vim.o.foldlevel = 99                     -- Set the initial fold level (99 = open everything)
vim.o.foldlevelstart = 99                -- Start with everything unfolded
vim.o.foldenable = true                  -- Enable folding
