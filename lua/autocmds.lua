require "nvchad.autocmds"

vim.api.nvim_create_user_command("CleanBin", function()
  local cmd = "/home/nerver/Desktop/dev/Leetcode/clean_all.sh"
  vim.cmd("tabnew") -- ou `vsplit`/`split` se preferir
  vim.fn.termopen(cmd)
end, {})

vim.api.nvim_create_user_command("CleanTxt", function()
  local cmd = "/home/nerver/Desktop/dev/testcases/clean_all.sh"
  vim.cmd("tabnew") -- ou `vsplit`/`split` se preferir
  vim.fn.termopen(cmd)
end, {})
