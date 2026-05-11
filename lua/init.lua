require('devpabs')

local function load_project_local()
  local file = vim.fn.getcwd() .. "/.nvim.local.lua"
  if vim.fn.filereadable(file) == 1 then
    dofile(file)
  end
end

load_project_local()

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
vim.opt.autoread = true
vim.opt.updatetime = 200

local group = vim.api.nvim_create_augroup("AutoRead", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function() vim.cmd("checktime") end,
})

require("lazy").setup({
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope.nvim', tag = '0.1.8'},
    {'rose-pine/neovim'},
    {'nvim-treesitter/nvim-treesitter'},
    {'mbbill/undotree'},
    {'tpope/vim-fugitive'},
    {
     "lewis6991/gitsigns.nvim",
     config = function()
       require("gitsigns").setup()
     end,
    },

    -- Mason for managing LSP servers
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},

    -- LSP setup
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x', lazy=false},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'L3MON4D3/LuaSnip'},
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

    {'jose-elias-alvarez/null-ls.nvim'},
    {'hiphish/rainbow-delimiters.nvim'},

    {
      "yetone/avante.nvim",
      cmd = {
        "AvanteAsk",
        "AvanteChat",
        "AvanteToggle",
        "AvanteClear",
      },
      version = false,
      build = "make",
      opts = {
        provider = "bedrock",
        providers = {
          bedrock = {
            model = "us.anthropic.claude-3-5-sonnet-20241022-v2:0",
            aws_region = "us-east-1",
          },
        },
        mappings = {
          ask = "<leader>aa",
          edit = "<leader>ae",
          refresh = "<leader>ar",
          suggestion = {
            accept = "<C-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<M-]>",
          },
	},
      },
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "echasnovski/mini.pick", -- for file_selector provider mini.pick
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        "ibhagwan/fzf-lua", -- for file_selector provider fzf
        "stevearc/dressing.nvim", -- for input provider dressing
        "folke/snacks.nvim", -- for input provider snacks
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
          -- support for image pasting
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            -- recommended settings
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              -- required for Windows users
              use_absolute_path = true,
            },
          },
        },
      },
    },
    {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
            "catppuccin", 
            "nightfox", 
            "dayfox", 
            "dawnfox", 
            "nordfox", 
            "terafox"
        }, -- Your list of installed colorschemes.
        livePreview = true, -- Apply theme while picking. Default to true.
      })
    end
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "EdenEast/nightfox.nvim" }, -- lazy


  -- Tmux integration
  {
    "christoomey/vim-tmux-navigator"
  },
  {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      filtered_items = {
        hide_dotfiles = false,
      },
    },
   },
  },
  -- bufdelete
  {
    "famiu/bufdelete.nvim",
  },
  -- Bufferline (nice tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          offsets = {
            {
              filetype = "neo-tree",
              text = "Neo-tree",
              separator = true,
            },
          },
          close_if_last_window = false,
        },
    })
    end,
  }
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
