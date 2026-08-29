local lspconfig = require("lspconfig")

-- Machine-local overrides; see lua/config/machine.example.lua. Absent on most
-- machines, which is the point -- the defaults below have to work unaided.
local ok_machine, machine = pcall(require, "config.machine")
machine = ok_machine and machine or {}

local cargo_target_dir = machine.cargo_target_dir or (vim.env.HOME .. "/.cargo/nvim-target")

local rustfmt_override = machine.rustfmt_override
if rustfmt_override and vim.fn.executable(rustfmt_override[1]) == 0 then
  vim.notify(
    ("rustfmt_override %q is not installed; using rust-analyzer's rustfmt"):format(rustfmt_override[1]),
    vim.log.levels.WARN
  )
  rustfmt_override = nil
end

-- TODO: Condense this duplication into a function

lspconfig.rust_analyzer.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    }),
  },
  settings = {
    ["rust-analyzer"] = {
      -- numThreads = 1,
      inlayHints = {
        enable = true,
      },
      hoverActions = {
        enable = true,
      },
      imports = {
        group = { enable = false },
        granularity = { enforce = true },
        prefix = "crate",
      },
      cargo = {
        features = "all",
        allTargets = true,
        extraEnv = {
          CARGO_TARGET_DIR = cargo_target_dir,
        },
      },
      -- Only override when a machine asks for it and the binary exists.
      -- Left unset, rust-analyzer uses its own rustfmt. A missing override
      -- binary is worse than none: leptosfmt echoes its input and exits 0,
      -- so formatting silently does nothing while appearing to succeed.
      rustfmt = rustfmt_override and { overrideCommand = rustfmt_override } or nil,
      procMacro = {
        enable = true,
      },
      checkOnSave = false,
      check = {
        -- command = "clippy",
        onSave = false,
      },
    },
  },
  on_attach = function(client, bufnr)
    -- Enable formatting capabilities
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true

    vim.api.nvim_create_autocmd("BufWritePre", {
      -- Grouped and cleared: this runs inside on_attach, so without a group a
      -- fresh copy was appended on every attach and every :LspRestart.
      group = vim.api.nvim_create_augroup("RustFormatOnSave", { clear = true }),
      pattern = "*.rs",
      callback = function()
        vim.lsp.buf.format({ async = true })
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

    _G.ra_flycheck = function(bufnr)
      local clients = (vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" }))
        or vim.lsp.get_active_clients({ bufnr = bufnr, name = "rust_analyzer" })

      local client = clients and clients[1]
      if not client then
        vim.notify("rust-analyzer is not attached to this buffer", vim.log.levels.WARN)
        return
      end

      local params = vim.lsp.util.make_text_document_params(bufnr)
      client.notify("rust-analyzer/runFlycheck", params)
    end

    _G.ra_restart = function(bufnr)
      local clients = (vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" }))
        or vim.lsp.get_active_clients({ bufnr = bufnr, name = "rust_analyzer" })

      local client = clients and clients[1]
      if not client then
        vim.notify("rust-analyzer is not attached to this buffer", vim.log.levels.WARN)
        return
      end

      -- Stop client
      client.stop()

      -- Restart after a tick
      vim.defer_fn(function()
        vim.cmd("LspStart rust_analyzer")
      end, 100)
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
      "<leader>cf",
      "<Cmd>lua vim.lsp.buf.format()<CR>",
      { desc = "Formatting", noremap = true, silent = true }
    )

    -- Rebuild proc-macro
    buf_set_keymap(
      "n",
      "<leader>rb",
      "<Cmd>lua _G.ra_restart(" .. bufnr .. ")<CR>",
      { desc = "Restart rust-analyzer", noremap = true, silent = true }
    )

    buf_set_keymap(
      "n",
      "<leader>rc",
      "<Cmd>lua _G.ra_flycheck(" .. bufnr .. ")<CR>",
      { desc = "Run rust-analyzer flycheck", noremap = true, silent = true }
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
      "<leader>cf",
      "<Cmd>lua vim.lsp.buf.format()<CR>",
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

lspconfig.pyright.setup({
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
      "<leader>cf",
      "<Cmd>lua vim.lsp.buf.format()<CR>",
      { desc = "Formatting", noremap = true, silent = true }
    )
    buf_set_keymap(
      "n",
      "<leader>R",
      "<Cmd>LspRestart<CR>",
      { desc = "Restart LSP Server", noremap = true, silent = true }
    )
  end,
})
