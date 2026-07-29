require "nvchad.mappings"
local python_config = require("configs.python_configs")

local map = vim.keymap.set
local dap = require("dap")
local dapui = require("dapui")

-- ========================
-- Utility functions
-- ========================

-- Function to get project root (prefers LSP root)
local function get_project_root()
  local clients = vim.lsp.get_active_clients()
  if clients[1] and clients[1].config and clients[1].config.root_dir then
    return clients[1].config.root_dir
  else
    return vim.fn.getcwd()
  end
end

-- Function to find venv activate path
local function get_activate_path(root_dir)
  local is_windows = vim.fn.has("win32") == 1
  local bin_dir = is_windows and "Scripts" or "bin"
  local act_name = is_windows and "activate.bat" or "activate"

  local candidates = {
    vim.fs.joinpath(root_dir, "venv", bin_dir, act_name),
    vim.fs.joinpath(root_dir, ".venv", bin_dir, act_name),
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

-- Robust helper for clangd / LSP quickfix code actions
local smart_code_action = function(apply)
  local cur_win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(cur_win)[1] - 1

  local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
  if #diags == 0 then
    vim.lsp.buf.code_action({ apply = apply })
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.lsp.buf.code_action({ apply = apply })
    return
  end

  local client = clients[1]
  local d = diags[1]

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = d.lnum, character = d.col or 0 },
      ["end"] = { line = d.end_lnum or d.lnum, character = d.end_col or ((d.col or 0) + 1) },
    },
    context = {
      diagnostics = { d.user_data and d.user_data.lsp or d },
      triggerKind = 1,
    },
  }

  client.request("textDocument/codeAction", params, function(err, result)
    if err or not result or #result == 0 then
      vim.lsp.buf.code_action({ apply = apply })
      return
    end

    if apply then
      if result[1].edit then
        vim.lsp.util.apply_workspace_edit(result[1].edit, client.offset_encoding)
      elseif result[1].command then
        client:exec_cmd(result[1].command)
      end
    else
      vim.lsp.buf.code_action({ apply = false })
    end
  end, bufnr)
end

-- ========================
-- Generic function to open terminal
-- ========================

local function open_terminal(cmd, autoclose)
  local split_cmd = vim.o.columns > 100 and "vsplit" or "split"
  vim.cmd(split_cmd)

  local term_win = vim.api.nvim_get_current_win()
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(term_win, term_buf)

  if autoclose then
    vim.fn.termopen(cmd, {
      on_exit = function(_, exit_code)
        vim.schedule(function()
          if exit_code == 0 then
            if vim.api.nvim_win_is_valid(term_win) then
              vim.api.nvim_win_close(term_win, true)
            end
            if vim.api.nvim_buf_is_valid(term_buf) then
              vim.api.nvim_buf_delete(term_buf, { force = true })
            end
            print("Successfully compiled C++ for debugging")
          else
            vim.notify("Compilation failed with exit code " .. exit_code, vim.log.levels.ERROR)
          end
        end)
      end
    })
  else
    local cmd_keep_open = cmd .. '; echo "\nPress ENTER to exit..."; read'
    vim.fn.termopen(cmd_keep_open)
  end

  vim.cmd("startinsert")
end

-- ========================
-- General keymaps
-- ========================

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
map("i", "ij", "<Esc>")
map("i", "ji", "<Esc>")

-- Leader + t n -> next tab
map("n", "<Leader>tn", ":tabnext<CR>", { noremap = true, silent = true, desc = "Next tab" })

-- Leader + t p -> previous tab (optional)
map("n", "<Leader>tp", ":tabprevious<CR>", { noremap = true, silent = true, desc = "Previous tab" })

-- ========================
-- Diagnostics & LSP
-- ========================
map("n", "<Leader>ca", function() smart_code_action(false) end, { desc = "Code Action" })
map("n", "<Leader>qf", function() smart_code_action(true) end, { desc = "Apply Quickfix / Code Action" })
map("n", "<Leader>cd", vim.diagnostic.open_float, { desc = "View diagnostic details" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- ========================
-- File execution
-- ========================

map("n", "<C-M-B>", function()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")
  local ext = vim.fn.expand("%:e")
  local output_name = vim.fn.expand("%:t:r")

  vim.cmd("w") -- save file

  local cmd = ""

  if ext == "cpp" then
    local compiler = vim.fn.executable("g++") == 1 and "g++" or "clang++"
    cmd = string.format(
      'cd "%s" && %s -std=c++23 -march=native -O2 -DLOCAL "%s" -o "%s" && "./%s"',
      dir, compiler, file, output_name, output_name
    )
  elseif ext == "py" then
    local root_dir = get_project_root()
    local activate_path = get_activate_path(root_dir)
    local relpath = file:sub(#root_dir + 2)
    local module_name = relpath:gsub("/", "."):gsub("%.py$", "")

    if activate_path then
      cmd = string.format('cd "%s" && source "%s" && python -m %s', root_dir, activate_path, module_name)
    else
      cmd = string.format('cd "%s" && python -m %s', root_dir, module_name)
    end

  elseif ext == "js" then
    cmd = string.format('node "%s"', file)
  elseif ext == "ts" then
    cmd = string.format('tsc "%s" && node "%s.js"', file, output_name)
  elseif ext == "sh" then
    cmd = string.format('bash "%s"', file)
  else
    print("Unsupported extension: " .. ext)
    return
  end

  open_terminal(cmd)
end, { noremap = true, silent = true, desc = "Open in terminal" })

-- ========================
-- DAP keymaps
-- ========================

vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "DAP Continue" })
vim.keymap.set("n", "<F6>", function() dap.step_over() end, { desc = "DAP Step Over" })
vim.keymap.set("n", "<F7>", function() dap.step_into() end, { desc = "DAP Step Into" })
vim.keymap.set("n", "<F8>", function() dap.step_out() end, { desc = "DAP Step Out" })

vim.keymap.set("n", "<Leader>b", function() dap.toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set("n", "<Leader>B", function()
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
    if condition then dap.set_breakpoint(condition) end
  end)
end, { desc = "DAP Conditional Breakpoint" })

vim.keymap.set("n", "<Leader>lp", function()
  vim.ui.input({ prompt = "Log point message: " }, function(msg)
    if msg then dap.set_breakpoint(nil, nil, msg) end
  end)
end, { desc = "DAP Log Point" })

vim.keymap.set("n", "<Leader>du", function() dapui.toggle() end, { desc = "DAP UI Toggle" })
vim.keymap.set("n", "<Leader>de", function() dapui.eval() end, { desc = "DAP Eval Expression" })
vim.keymap.set("v", "<Leader>de", function() dapui.eval() end, { desc = "DAP Eval Selection" })

vim.keymap.set("n", "<Leader>dc", function() dap.run_to_cursor() end, { desc = "DAP Run to Cursor" })
vim.keymap.set("n", "<Leader>dr", function() dap.restart() end, { desc = "DAP Restart" })
vim.keymap.set("n", "<Leader>dl", function() dap.run_last() end, { desc = "DAP Run Last" })
vim.keymap.set("n", "<Leader>dL", function()  dapui.float_element("scopes") end, { desc = "Floating locals" })
vim.keymap.set("n", "<Leader>dw", function() dapui.float_element("watches") end, { desc = "Floating watches" })

vim.keymap.set("n", "<Leader>ds", function()
  dapui.close()
  dap.terminate()
  dap.disconnect()
  dap.clear_breakpoints()

  pcall(function()
    local vt = require("nvim-dap-virtual-text")
    vt.disable()
    vt.refresh()
  end)

  vim.cmd("redraw")
end, { desc = "DAP Stop & Clean" })

-- ========================
-- C++ compilation for debugging
-- ========================

map("n", "<C-A-d>", function()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")
  local output_name = vim.fn.expand("%:t:r")

  vim.cmd("w")

  local compiler = vim.fn.executable("g++") == 1 and "g++" or "clang++"
  local compile_cmd = string.format(
    "%s -g -O0 -DLOCAL -std=c++23 '%s' -o '%s/%s'",
    compiler, file, dir, output_name
  )
  open_terminal(compile_cmd, true)
end, { noremap = true, silent = true, desc = "Compile C++ for debugging" })

-- ======
-- NEOGEN
-- ======
map("n", "<leader>ng", ":Neogen<CR>", { desc = "Generate docstring via Neogen" })
