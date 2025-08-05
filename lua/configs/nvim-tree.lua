local M = {}

M.setup = function()
  require("nvim-tree").setup({
    git = {
      enable = true,
      ignore = false,
    },
    filters = {
      dotfiles = false,
      custom = { "^.git$" }, -- esconde apenas a pasta .git
    },
    sync_root_with_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    hijack_directories = {
      enable = false,
    },
    view = {
      preserve_window_proportions = true,
    },
    renderer = {
      root_folder_label = false, -- ❌ remove exibição do nome do root
    },
  })

  -- Força o root do tree para o cwd no início
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local api = require("nvim-tree.api")
      local cwd = vim.fn.getcwd()
      api.tree.change_root(cwd)
    end,
  })
end

return M
