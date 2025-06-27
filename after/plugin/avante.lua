require("avante").setup({
  provider = "bedrock",
  providers = {
      bedrock = {
         model = "us.anthropic.claude-3-5-sonnet-20241022-v2:0",
         aws_region = "us-east-1",
        },
   },
  input = {
    provider = "dressing", -- "native" | "dressing" | "snacks"
    provider_opts = {
      -- Snacks input configuration
      title = "Avante Input",
      icon = " ",
      placeholder = "Enter your API key...",
    },
  },
  mappings = {
    ask = "<leader>aa",    -- \aa to query Ollama
    edit = "<leader>ae",   -- \ae to edit code
    refresh = "<leader>ar", -- \ar to refresh
    suggestion = {
      accept = "<C-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<M-]>",
    },
  },
  windows = {
    position = "right", -- Fits your tmux splits
    width = 30,
  },
  behaviour = {
    auto_suggestions = true
  },
})
