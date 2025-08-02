require "nvchad.mappings"
local python_config = require("configs.python_configs")

local map = vim.keymap.set
local dap = require("dap")
local dapui = require("dapui")

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
  local sep = package.config:sub(1,1)
  local candidates = {
    root_dir .. sep .. "venv" .. sep .. "bin" .. sep .. "activate",
    root_dir .. sep .. ".venv" .. sep .. "bin" .. sep .. "activate",
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")

map("n", "<C-M-B>", function()
  local file = vim.fn.expand("%:p")         -- caminho absoluto do arquivo atual
  local dir = vim.fn.fnamemodify(file, ":h")-- diretório do arquivo
  local ext = vim.fn.expand("%:e")
  local output_name = vim.fn.expand("%:t:r")-- nome do arquivo sem extensão (base name)
  local exec_path = dir .. "/" .. output_name

  vim.cmd("w") -- salva arquivo

  local cmd = ""

  if ext == "cpp" then
    cmd = string.format(
      "gnome-terminal -- bash -c 'cd \"%s\" && g++ -std=c++23 -march=native -O2 \"%s\" -o \"%s\" && ./\"%s\"; exec bash'",
      dir, file, output_name, output_name
    )
  elseif ext == "py" then
    local root_dir = get_project_root()
    local activate_path = get_activate_path(root_dir)

    if activate_path then
      cmd = string.format(
        "gnome-terminal -- bash -c 'source \"%s\" && python \"%s\"; exec bash'",
        activate_path,
        file
      )
    else
      -- fallback para python global se não achar venv
      cmd = string.format(
        "gnome-terminal -- bash -c 'python \"%s\"; exec bash'",
        file
      )
    end

  elseif ext == "js" then
    cmd = string.format("gnome-terminal -- bash -c 'node \"%s\"; exec bash'", file)
  elseif ext == "ts" then
    cmd = string.format("gnome-terminal -- bash -c 'tsc \"%s\" && node \"%s.js\"; exec bash'", file, output_name)
  elseif ext == "sh" then
    cmd = string.format("gnome-terminal -- bash -c 'bash \"%s\"; exec bash'", file)
  else
    print("Extensão não suportada para execução automática: " .. ext)
    return
  end

  os.execute(cmd)
end, { noremap = true, silent = true, desc = "Abrir em terminal externo" })


-- DAP keymaps
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
vim.keymap.set("n", "<Leader>dl", function()  dapui.float_element("scopes") end, { desc = "Floating locals" })
vim.keymap.set("n", "<Leader>dw", function() dapui.float_element("watches") end, { desc = "Floating watches" })

vim.keymap.set("n", "<Leader>ds", function()
  local dap = require("dap")
  local dapui = require("dapui")

  -- Fecha UI do DAP
  dapui.close()

  -- Termina e desconecta sessão
  dap.terminate()
  dap.disconnect()
  dap.clear_breakpoints()

  -- Desativa virtual text e força limpeza
  pcall(function()
    local vt = require("nvim-dap-virtual-text")
    vt.disable()
    vt.refresh()  -- força a limpeza do overlay atual
  end)

  -- Redesenha a tela
  vim.cmd("redraw")
end, { desc = "DAP Stop & Clean" })

--Compiling C++ for debugging
map("n", "<C-A-d>", function()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")
  local output_name = vim.fn.expand("%:t:r")

  vim.cmd("w")

  local compile_cmd = string.format(
    "g++ -g -O0 -std=c++23 '%s' -o '%s/%s'",
    file, dir, output_name
  )
  local result = vim.fn.system(compile_cmd)

  if vim.v.shell_error == 0 then
    print("Successfully compiled C++ for debugging")
  else
    print("Compilation failed:\n" .. result)
  end
end, { noremap = true, silent = true, desc = "Compilar C++ para debug (sem terminal)" })
