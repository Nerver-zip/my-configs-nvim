return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()
    -- Ativa/desativa virtual text automaticamente com eventos do DAP
    local ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
    if ok then
      dap.listeners.after.event_initialized["dap-virtual-text-toggle"] = function()
        dap_virtual_text.enable()
      end

      dap.listeners.before.event_terminated["dap-virtual-text-toggle"] = function()
        dap_virtual_text.disable()
      end

      dap.listeners.before.event_exited["dap-virtual-text-toggle"] = function()
        dap_virtual_text.disable()
      end
    end

        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- Setup C++ DAP Adapter dynamically
    local adapter_type = "cppdbg"
    local cppdbg_path = vim.fn.stdpath("data") .. "/debug/bin/OpenDebugAD7"

    if vim.fn.filereadable(cppdbg_path) == 1 then
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = cppdbg_path,
      }
      adapter_type = "cppdbg"
    else
      -- Check for system lldb-dap/lldb-vscode or gdb
      local lldb_bin = vim.fn.executable("lldb-dap") == 1 and "lldb-dap"
        or (vim.fn.executable("lldb-vscode") == 1 and "lldb-vscode" or nil)
      if lldb_bin then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_bin,
          name = "lldb",
        }
        adapter_type = "lldb"
      elseif vim.fn.executable("gdb") == 1 then
        dap.adapters.gdb = {
          type = "executable",
          command = "gdb",
          args = { "-i", "dap" },
        }
        adapter_type = "gdb"
      else
        adapter_type = nil
      end
    end

    if adapter_type then
      local config = {
        name = "Launch",
        type = adapter_type,
        request = "launch",
        program = function()
          local filepath = vim.fn.expand("%:p")          -- caminho completo do arquivo atual
          local dir = vim.fn.fnamemodify(filepath, ":h") -- diretório do arquivo
          local output_name = vim.fn.expand("%:t:r")     -- nome do arquivo sem extensão
          return vim.fs.joinpath(dir, output_name)
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
      }

      if adapter_type == "cppdbg" then
        config.setupCommands = {
          {
            text = "-enable-pretty-printing",
            description = "Enable pretty printing",
            ignoreFailures = true,
          },
        }
      end

      dap.configurations.cpp = { config }
    end
  end,
}
