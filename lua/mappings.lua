require "nvchad.mappings"
local python_config = require("configs.python_configs")

local map = vim.keymap.set
local dap = require("dap")
local dapui = require("dapui")

-- ========================
-- Funções utilitárias
-- ========================

-- Função para obter root do projeto (prefere root do LSP)
local function get_project_root()
  local clients = vim.lsp.get_active_clients()
  if clients[1] and clients[1].config and clients[1].config.root_dir then
    return clients[1].config.root_dir
  else
    return vim.fn.getcwd()
  end
end

-- Função para buscar caminho do activate do venv
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

-- ========================
-- Função genérica para abrir terminal externo ou interno
-- ========================

local function open_terminal(cmd)
  local term = os.getenv("TERMINAL") or "kitty"
  local shell = os.getenv("SHELL") or vim.o.shell or "sh"

  -- adiciona read para manter terminal aberto
  local cmd_keep_open = cmd .. '; echo "\nPress ENTER to exit..."; read'

  local is_android = vim.fn.has("android") == 1
  local has_gui = (vim.env.DISPLAY ~= nil or vim.env.WAYLAND_DISPLAY ~= nil)

  if is_android or not has_gui or vim.fn.executable(term) == 0 then
    -- Abre no terminal embutido do Neovim
    local split_cmd = vim.o.columns > 100 and "vsplit" or "split"
    vim.cmd(split_cmd .. " | terminal " .. cmd_keep_open)
  else
    -- Executa em background via jobstart
    vim.fn.jobstart({ term, shell, "-c", cmd_keep_open }, { detach = true })
    vim.cmd("redraw")
  end
end

-- ========================
-- Keymaps gerais
-- ========================

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
map("i", "ij", "<Esc>")
map("i", "ji", "<Esc>")

-- Leader + t n → próxima tab
map("n", "<Leader>tn", ":tabnext<CR>", { noremap = true, silent = true, desc = "next tab" })

-- Leader + t p → tab anterior (opcional)
map("n", "<Leader>tp", ":tabprevious<CR>", { noremap = true, silent = true, desc = "previous tab" })

-- ========================
-- Execução de arquivos
-- ========================

map("n", "<C-M-B>", function()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")
  local ext = vim.fn.expand("%:e")
  local output_name = vim.fn.expand("%:t:r")

  vim.cmd("w") -- salva arquivo

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
    print("Extensão não suportada: " .. ext)
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
-- Compilação C++ para debug
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
  local result = vim.fn.system(compile_cmd)

  if vim.v.shell_error == 0 then
    print("Successfully compiled C++ for debugging")
  else
    print("Compilation failed:\n" .. result)
  end
end, { noremap = true, silent = true, desc = "Compilar C++ for debugging" })

-- ======
-- NEOGEN
-- ======
map("n", "<leader>ng", ":Neogen<CR>", { desc = "Generate docstring via Neogen" })
