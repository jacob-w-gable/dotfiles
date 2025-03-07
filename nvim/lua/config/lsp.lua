local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    }),
  },
  settings = {
    ["rust-analyzer"] = {
      numThreads = 1,
      inlayHints = {
        enable = true,
      },
      hoverActions = {
        enable = true,
      },
    },
  },
  on_attach = function(client, bufnr)
    -- Enable formatting capabilities
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.rs",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })

    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<leader>h",
      "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>",
      { noremap = true, silent = true, desc = "Toggle inlay hints" }
    )

    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    buf_set_keymap(
      "n",
      "gd",
      "<Cmd>lua vim.lsp.buf.definition()<CR>",
      { desc = "Go to Definition", noremap = true, silent = true }
    )
    buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover", noremap = true, silent = true })
    buf_set_keymap(
      "n",
      "gI",
      "<Cmd>lua vim.lsp.buf.implementation()<CR>",
      { desc = "Implementation", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<C-k>",
      "<Cmd>lua vim.lsp.buf.signature_help()<CR>",
      { desc = "Signature Help", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>cr",
      "<Cmd>lua vim.lsp.buf.rename()<CR>",
      { desc = "Rename", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>ca",
      "<Cmd>lua vim.lsp.buf.code_action()<CR>",
      { desc = "Code Action", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "gr",
      "<Cmd>lua vim.lsp.buf.references()<CR>",
      { desc = "References", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>f",
      "<Cmd>lua vim.lsp.buf.formatting()<CR>",
      { desc = "Formatting", noremap = true, silent = true }
    )

    -- Rebuild proc-macro
    buf_set_keymap(
      "n",
      "<leader>rb",
      "<Cmd>lua require('rust-tools.proc-macro').rebuild()<CR>",
      { desc = "Rebuild proc-macro", noremap = true, silent = true }
    )
  end,
})

lspconfig.tsserver.setup({
  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    }),
  },
  on_attach = function(client, bufnr)
    -- Disable tsserver formatting if using something else like prettier
    client.server_capabilities.documentFormattingProvider = false

    -- Mappings for LSP (you can customize these)
    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    buf_set_keymap(
      "n",
      "gd",
      "<Cmd>lua vim.lsp.buf.definition()<CR>",
      { desc = "Go to Definition", noremap = true, silent = true }
    )
    buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover", noremap = true, silent = true })
    buf_set_keymap(
      "n",
      "gI",
      "<Cmd>lua vim.lsp.buf.implementation()<CR>",
      { desc = "Implementation", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<C-k>",
      "<Cmd>lua vim.lsp.buf.signature_help()<CR>",
      { desc = "Signature Help", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>cr",
      "<Cmd>lua vim.lsp.buf.rename()<CR>",
      { desc = "Rename", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>ca",
      "<Cmd>lua vim.lsp.buf.code_action()<CR>",
      { desc = "Code Action", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "gr",
      "<Cmd>lua vim.lsp.buf.references()<CR>",
      { desc = "References", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>f",
      "<Cmd>lua vim.lsp.buf.formatting()<CR>",
      { desc = "Formatting", noremap = true, silent = true }
    )
  end,

  -- You can include additional settings here
  settings = {
    -- Ensure that all types are suggested
    completions = {
      completeFunctionCalls = true,
    },
  },
})
