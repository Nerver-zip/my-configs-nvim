local has_mason, mason = pcall(require, "mason")
local has_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local cmp = require("cmp")
local python_config = require("configs.python_configs")

-- Setup Mason and mason-lspconfig (if available)
if has_mason then
  mason.setup()
end

if has_mason_lsp then
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
      "vhdl_ls",
    },
  }
end

-- Capabilities for autocompletion
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Robust helper for clangd / LSP quickfix code actions
local smart_code_action = function(apply)
  local cur_win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(cur_win)[1] - 1

  local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
  if #diags == 0 then
    vim.lsp.buf.code_action({ apply = apply })
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.lsp.buf.code_action({ apply = apply })
    return
  end

  local client = clients[1]
  local d = diags[1]

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = d.lnum, character = d.col or 0 },
      ["end"] = { line = d.end_lnum or d.lnum, character = d.end_col or ((d.col or 0) + 1) },
    },
    context = {
      diagnostics = { d.user_data and d.user_data.lsp or d },
      triggerKind = 1,
    },
  }

  client.request("textDocument/codeAction", params, function(err, result)
    if err or not result or #result == 0 then
      vim.lsp.buf.code_action({ apply = apply })
      return
    end

    if apply then
      if result[1].edit then
        vim.lsp.util.apply_workspace_edit(result[1].edit, client.offset_encoding)
      elseif result[1].command then
        client:exec_cmd(result[1].command)
      end
    else
      vim.lsp.buf.code_action({ apply = false })
    end
  end, bufnr)
end

-- on_attach function for LSP keymaps
local on_attach = function(client, bufnr)
  local buf_map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  buf_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  buf_map("n", "K", vim.lsp.buf.hover, "Hover")
  buf_map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  buf_map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  buf_map("n", "<leader>ca", function() smart_code_action(false) end, "Code action")
  buf_map("n", "<leader>qf", function() smart_code_action(true) end, "Apply Quickfix / Code Action")
  buf_map("n", "<leader>cd", vim.diagnostic.open_float, "View diagnostic details")
  buf_map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  buf_map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  buf_map("n", "gr", vim.lsp.buf.references, "References")
  buf_map("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, "Format file")
end

-- Custom handler to filter duplicated diagnostics
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

-- Visual diagnostics configuration
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

-- Servers
local servers = {
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=never",
      "--query-driver=*",
    },
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
  lua_ls = {},
  emmet_ls = {},
  tailwindcss = {},
  jsonls = {},
  eslint = {},
}

if vim.lsp.config then
  for server, opts in pairs(servers) do
    opts.capabilities = capabilities
    opts.on_attach = on_attach
    vim.lsp.config(server, opts)
    vim.lsp.enable(server)
  end
else
  local lspconfig = require("lspconfig")
  for server, opts in pairs(servers) do
    opts.capabilities = capabilities
    opts.on_attach = on_attach
    lspconfig[server].setup(opts)
  end
end

-- nvim-cmp configuration for autocomplete
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
    ["<C-.>"] = function() smart_code_action(false) end,
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
})
