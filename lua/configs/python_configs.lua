local M = {}

function M.get_python_path()
  local root_dir = vim.fn.getcwd()

  -- Detect platform differences dynamically
  local is_windows = vim.fn.has("win32") == 1
  local bin_dir = is_windows and "Scripts" or "bin"
  local exe_name = is_windows and "python.exe" or "python"

  -- Valid candidates for virtual environment python
  local candidates = {
    vim.fs.joinpath(root_dir, ".venv", bin_dir, exe_name),
    vim.fs.joinpath(root_dir, "venv", bin_dir, exe_name),
  }

  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Global fallback
  local global_py = vim.fn.exepath("python3")
  if global_py == "" then
    global_py = vim.fn.exepath("python")
  end
  return global_py ~= "" and global_py or "python3"
end

return M
