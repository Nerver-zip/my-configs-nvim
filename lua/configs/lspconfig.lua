local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local cmp = require("cmp")
local python_config = require("configs.python_configs")

-- Setup Mason e mason-lspconfig
mason.setup()
mason_lspconfig.setup {
  ensure_installed = {
    "clangd",
    "pyright",
    "html",
    "cssls",
    "ts_ls",
    "bashls",
    "emmet_ls",
    "tailwindcss",
    "jsonls",
    "eslint",
    "lua_ls",
    "vhdl_ls"
    },
}

-- Capabilities para autocompletion
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Função on_attach para keymaps LSP
local on_attach = function(client, bufnr)
  local buf_map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  buf_map("n", "gd", vim.lsp.buf.definition, "Ir para definição")
  buf_map("n", "K", vim.lsp.buf.hover, "Hover")
  buf_map("n", "gi", vim.lsp.buf.implementation, "Ir para implementação")
  buf_map("n", "<leader>rn", vim.lsp.buf.rename, "Renomear símbolo")
  buf_map("n", "<leader>ca", vim.lsp.buf.code_action, "Ação de código")
  buf_map("n", "gr", vim.lsp.buf.references, "Referências")
  buf_map("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, "Formatar arquivo")
end

-- Handler customizado para filtrar diagnósticos repetidos
local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, method, diagnostics, client_id, bufnr, config)
  local filtered, seen = {}, {}
  for _, diag in ipairs(diagnostics) do
    local key = diag.lnum .. ":" .. diag.severity
    if not seen[key] then
      table.insert(filtered, diag)
      seen[key] = true
    end
  end
  original_handler(err, method, filtered, client_id, bufnr, config)
end

-- Configuração de diagnósticos visuais
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
    format = function(diagnostic) return diagnostic.message end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    source = "always",
  },
})

vim.o.updatetime = 300

-- Servidores
local servers = {
  clangd = {
    cmd = { "clangd" },
  },
  pyright = {
    before_init = function(_, config)
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = python_config.get_python_path()
    end,
  },
  html = {},
  cssls = {},
  ts_ls = {},
  bashls = {},
  vhdl_ls = {},
}

-- Detecta se estamos em nvim 0.11+
if vim.lsp.config then
  -- Defaults globais
  vim.lsp.config("*", { capabilities = capabilities, on_attach = on_attach })

  -- Configuração individual
  for server, opts in pairs(servers) do
    vim.lsp.config(server, opts)
    vim.lsp.enable(server)
  end
else
  -- Compatibilidade com nvim <= 0.10
  local lspconfig = require("lspconfig")
  for server, opts in pairs(servers) do
    opts.capabilities = capabilities
    opts.on_attach = on_attach
    lspconfig[server].setup(opts)
  end
end

-- Configuração do nvim-cmp para autocomplete
cmp.setup({
  mapping = {
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
    ["<C-.>"] = function() vim.lsp.buf.code_action() end,
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
})
