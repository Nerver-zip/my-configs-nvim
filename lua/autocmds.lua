require("nvchad.autocmds")

local api = vim.api
local fn = vim.fn

-- =========================================================
-- Utils
-- =========================================================

local function open_term(cmd)
  local expanded_cmd = cmd
  if cmd:sub(1, 1) == "~" then
    expanded_cmd = vim.fn.expand(cmd)
  end

  -- Extract the executable/script to verify it exists
  local parts = vim.split(expanded_cmd, " ")
  local exe = parts[1]
  if vim.fn.executable(exe) == 0 then
    vim.notify("Command or script not found/executable: " .. exe, vim.log.levels.ERROR)
    return
  end

  vim.cmd.tabnew()
  fn.termopen(expanded_cmd)
end

local function create_term_cmd(name, cmd)
  api.nvim_create_user_command(name, function(opts)
    local actual_cmd = type(cmd) == "function" and cmd() or cmd
    if type(actual_cmd) == "string" and actual_cmd:sub(1, 1) == "~" then
      actual_cmd = vim.fn.expand(actual_cmd)
    end
    local full_cmd = opts.args ~= "" and (actual_cmd .. " " .. opts.args) or actual_cmd
    open_term(full_cmd)
  end, {
    nargs = "*",
  })
end

local function insert_template(filename, opts)
  opts = opts or {}

  local template =
    vim.fs.joinpath(vim.fn.stdpath("config"), "templates", filename)

  local lines = fn.readfile(template)

  if opts.top then
    api.nvim_buf_set_lines(0, 0, 0, false, lines)
  else
    local row = unpack(api.nvim_win_get_cursor(0))
    api.nvim_buf_set_lines(0, row, row, false, lines)
  end

  if opts.cursor then
    api.nvim_win_set_cursor(0, opts.cursor)
  else
    local row = unpack(api.nvim_win_get_cursor(0))
    api.nvim_win_set_cursor(0, { row + #lines, 0 })
  end
end

local function find_root()
  local root = vim.fs.root(0, { ".git" })
  return root or fn.getcwd()
end

-- =========================================================
-- Terminal Commands
-- =========================================================

create_term_cmd(
  "CleanBin",
  "~/Desktop/dev/Leetcode/clean_all.sh"
)

create_term_cmd(
  "CleanTxt",
  "~/Desktop/dev/testcases/clean_all.sh"
)

create_term_cmd("Diff", "diff output.txt expected.txt")

create_term_cmd("Dev", "npm run dev")

api.nvim_create_user_command("RunSh", function(opts)
  local script = vim.fs.joinpath(find_root(), "run.sh")
  local cmd = opts.args ~= "" and (script .. " " .. opts.args) or script

  open_term(cmd)
end, {
  nargs = "*",
})

-- =========================================================
-- Buffers
-- =========================================================

api.nvim_create_user_command("Bdall", function()
  local current = api.nvim_get_current_buf()

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if
      buf ~= current
      and api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == ""
    then
      api.nvim_buf_delete(buf, {})
    end
  end
end, {})

-- =========================================================
-- Python Virtual Envs
-- =========================================================

local function detect_venv_python()
  local root = fn.getcwd()

  for _, venv in ipairs({ ".venv", "venv", "venv.bak" }) do
    local py = vim.fs.joinpath(root, venv, "bin", "python")

    if fn.filereadable(py) == 1 then
      return py
    end
  end
end

api.nvim_create_user_command("CreatePyEnv", function(opts)
  local root = fn.getcwd()
  local name = opts.args ~= "" and opts.args or ".venv"

  local venv_dir = vim.fs.joinpath(root, name)
  local python_bin = vim.fs.joinpath(venv_dir, "bin", "python")

  if fn.isdirectory(venv_dir) == 1 then
    vim.notify(
      "Virtual environment already exists: " .. venv_dir,
      vim.log.levels.WARN
    )
    return
  end

  vim.notify("Creating virtual environment...", vim.log.levels.INFO)

  vim.system({ "python3", "-m", "venv", venv_dir }):wait()

  if fn.filereadable(python_bin) == 1 then
    vim.g.python3_host_prog = python_bin

    vim.notify(
      "Virtual environment activated: " .. python_bin,
      vim.log.levels.INFO
    )
  else
    vim.notify("Failed to create virtual environment", vim.log.levels.ERROR)
  end
end, {
  nargs = "?",
})

api.nvim_create_user_command("PyEnv", function()
  local python = detect_venv_python()

  if not python then
    vim.notify(
      "No virtual environment found",
      vim.log.levels.WARN
    )
    return
  end

  vim.g.python3_host_prog = python

  vim.notify(
    "Virtual environment activated: " .. python,
    vim.log.levels.INFO
  )
end, {})

-- =========================================================
-- Templates
-- =========================================================

local templates = {
  CP = {
    file = "cpp_template.cpp",
    top = true,
    cursor = { 6, 0 },
  },

  CF = {
    file = "CF.cpp",
    top = true,
    cursor = { 29, 4 },
  },

  UF = { file = "UF.cpp" },
  IsPrime = { file = "isPrime.cpp" },
  Sieve = { file = "sieve.cpp" },
  PolyHash = { file = "PolyHash.cpp" },
  Mod = { file = "mod.cpp" },
  SPF = { file = "SPF.cpp" },
  LCA = { file = "LCA.cpp" },
  BIT = { file = "BIT.cpp" },
}

for command, config in pairs(templates) do
  api.nvim_create_user_command(command, function()
    insert_template(config.file, config)
  end, {})
end
