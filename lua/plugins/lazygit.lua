return {
  "kdheepak/lazygit.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open LazyGit" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
