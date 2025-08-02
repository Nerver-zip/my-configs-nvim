local M = {}

function M.get_python_path()
  local root_dir = vim.fn.getcwd()

  -- Candidatos válidos no Linux
  local candidates = {
    root_dir .. "/.venv/bin/python",
    root_dir .. "/venv/bin/python",
  }

  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Fallback global
  return vim.fn.exepath("python3") or "python3"
end

return M
