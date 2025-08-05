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

--Running .sh scripts
local function find_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd()
  end
  return git_root
end

vim.api.nvim_create_user_command("RunSh", function(opts)
  local root = find_root()
  local script = root .. "/run.sh"
  local args = opts.args  -- aqui pega os argumentos passados ao :RunSh
  local cmd = script .. " " .. args
  vim.cmd("tabnew")
  vim.fn.termopen(cmd)
end, {
  nargs = "*"  -- aceita zero ou mais argumentos
})
--Fecha todos os buffers exceto o aberto atualmente
vim.api.nvim_create_user_command("Bdall", function()
  vim.cmd("%bd | e# | bd#")
end, {})


--Python Envs
local function detect_venv_python()
  local root = vim.fn.getcwd()
  local candidates = { ".venv", "venv", "venv.bak" }
  for _, venv in ipairs(candidates) do
    local py = root .. "/" .. venv .. "/bin/python"
    if vim.fn.filereadable(py) == 1 then
      return py
    end
  end
  return nil
end

--Cria ambiente virtual python
vim.api.nvim_create_user_command("CreatePyEnv", function(opts)
  local root = vim.fn.getcwd()
  local name = opts.args ~= "" and opts.args or ".venv"
  local venv_dir = root .. "/" .. name
  local python_bin = venv_dir .. "/bin/python"

  if vim.fn.isdirectory(venv_dir) == 1 then
    vim.notify("Ambiente virtual já existe em: " .. venv_dir, vim.log.levels.WARN)
    return
  end

  local cmd = string.format("python3 -m venv %s", venv_dir)
  vim.notify("Criando ambiente virtual '" .. name .. "'... aguarde", vim.log.levels.INFO)
  vim.fn.system(cmd)

  if vim.fn.isdirectory(venv_dir) == 1 and vim.fn.filereadable(python_bin) == 1 then
    vim.g.python3_host_prog = python_bin
    vim.notify("Ambiente virtual criado e ativado: " .. python_bin, vim.log.levels.INFO)
  else
    vim.notify("Falha ao criar ambiente virtual.", vim.log.levels.ERROR)
  end
end, { nargs = "?" })

--Ativa ambiente virtual python
vim.api.nvim_create_user_command("PyEnv", function()
  local python_path = detect_venv_python()
  if python_path then
    vim.g.python3_host_prog = python_path
    vim.notify("Ambiente virtual ativado: " .. python_path, vim.log.levels.INFO)
  else
    vim.notify("Nenhum ambiente virtual encontrado (.venv, venv, venv.bak)", vim.log.levels.WARN)
  end
end, {})
