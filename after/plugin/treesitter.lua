require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "python", "javascript", "typescript", "c", "lua", "bash", "json", "html", "css", "yaml", "markdown", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },


  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-bracket delimiters like html tags
    max_file_lines = 1000, -- Disable for files with more than 1000 lines
  },

  folding = {
    enable = true,  -- enable folding support
    disable = {},  -- disable folding for certain languages if needed
  },
}
