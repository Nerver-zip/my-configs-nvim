return {
  -- Desativar plugins pesados do NvChad que consomem CPU/RAM desnecessariamente no K6
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "hrsh7th/nvim-cmp", enabled = false },
  { "L3MON4D3/LuaSnip", enabled = false },
  { "folke/which-key.nvim", enabled = false },
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "lewis6991/gitsigns.nvim", enabled = false },
  { "stevearc/conform.nvim", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
  { "neovim/nvim-lspconfig", enabled = false },

  -- Treesitter com foco estrito em linguagens essenciais e alta performance
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "python",
        "javascript",
        "bash",
        "lua",
        "html",
        "css",
        "json",
        "markdown",
        "vim",
        "vimdoc",
      },
      highlight = {
        enable = true,
        use_languagetree = true,
      },
      indent = {
        enable = true,
      },
    },
  },
}
