return {
  "kdheepak/lazygit.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Abrir LazyGit (flutuante)" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
