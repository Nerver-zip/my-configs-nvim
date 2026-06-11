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

-- Diff entre output e expected
vim.api.nvim_create_user_command("Diff", function()
  local cmd = "diff output.txt expected.txt"
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

--Fechar todos os buffers
vim.api.nvim_create_user_command("Bdall", function()
  local current = vim.api.nvim_get_current_buf()
  local bufs = vim.api.nvim_list_bufs()

  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(b) and b ~= current then
      -- não tenta fechar buffers especiais como NvimTree, lazy, etc
      local bt = vim.bo[b].buftype
      if bt == "" then
        vim.api.nvim_buf_delete(b, {})
      end
    end
  end
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

-- Roda "npm run dev" em um terminal numa nova aba
vim.api.nvim_create_user_command("Dev", function()
  local cmd = "npm run dev"
  vim.cmd("tabnew")
  vim.fn.termopen(cmd)
  --vim.cmd("startinsert") -> já entra em modo insert dentro do terminal
end, {})

----===============TEMPLATES=========================
-- Insere um template para C++ para leetcode contest
vim.api.nvim_create_user_command("CP", function()
  local template = vim.fn.stdpath("config") .. "/templates/cpp_template.cpp"
  -- lê o arquivo e insere no buffer atual
  vim.cmd("0r " .. template)
  vim.api.nvim_win_set_cursor(0, {6, 0})
end, {})

-- UF (DSU)
vim.api.nvim_create_user_command("UF", function()
    local template = vim.fn.stdpath("config") .. "/templates/UF.cpp"

    -- posição atual do cursor
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- lê as linhas do template
    local lines = vim.fn.readfile(template)

    -- insere as linhas na posição atual
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)

    -- move o cursor para o final do bloco colado
    local new_row = row + #lines
    local new_col = #lines[#lines] -- última coluna da última linha
    vim.api.nvim_win_set_cursor(0, {new_row, new_col})
end, {})

-- IsPrime
vim.api.nvim_create_user_command("IsPrime", function()
    local template = vim.fn.stdpath("config") .. "/templates/isPrime.cpp"
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.fn.readfile(template)
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    local new_row = row + #lines
    local new_col = #lines[#lines]
    vim.api.nvim_win_set_cursor(0, {new_row, new_col})
end, {})

-- Sieve of Eratosthenes
vim.api.nvim_create_user_command("Sieve", function()
    local template = vim.fn.stdpath("config") .. "/templates/sieve.cpp"
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.fn.readfile(template)
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    local new_row = row + #lines
    local new_col = #lines[#lines]
    vim.api.nvim_win_set_cursor(0, {new_row, new_col})
end, {})

-- PolyHash
vim.api.nvim_create_user_command("PolyHash", function()
    local template = vim.fn.stdpath("config") .. "/templates/PolyHash.cpp"
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.fn.readfile(template)
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    local new_row = row + #lines
    local new_col = #lines[#lines]
    vim.api.nvim_win_set_cursor(0, {new_row, new_col})
end, {})

-- Beecrowd
vim.api.nvim_create_user_command("BC", function()
  local template = vim.fn.stdpath("config") .. "/templates/beecrowd.cpp"
  -- lê o arquivo e insere no buffer atual
  vim.cmd("0r " .. template)
  vim.api.nvim_win_set_cursor(0, {159, 0})
end, {})

-- SPF 
vim.api.nvim_create_user_command("SPF", function()
    local template = vim.fn.stdpath("config") .. "/templates/SPF.cpp"
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.fn.readfile(template)
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    local new_row = row + #lines
    local new_col = #lines[#lines]
    vim.api.nvim_win_set_cursor(0, {new_row, new_col})
end, {})
