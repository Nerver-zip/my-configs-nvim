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

    -- Adaptador GDB (exemplo com OpenDebugAD7)
    dap.adapters.cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = vim.fn.stdpath("data") .. "/debug/bin/OpenDebugAD7",
}
  dap.configurations.cpp = {
      {
        name = "Launch",
        type = "cppdbg",
        request = "launch",
        program = function()
          local filepath = vim.fn.expand("%:p")          -- caminho completo do arquivo atual
          local dir = vim.fn.fnamemodify(filepath, ":h") -- diretório do arquivo
          local output_name = vim.fn.expand("%:t:r")     -- nome do arquivo sem extensão
          return dir .. "/" .. output_name                 -- executável esperado
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
        setupCommands = {
          {
            text = "-enable-pretty-printing",
            description = "Enable pretty printing",
            ignoreFailures = true,
          },
        },
      },
    }
  end,
}
