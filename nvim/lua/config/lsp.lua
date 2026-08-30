-- LSP keymaps, and the rust-analyzer helpers they call.
--
-- Server settings live in lua/plugins/lspconfig.lua, layered onto LazyVim's
-- spec. nvim-lspconfig is lazy-loaded, and it puts the per-server defaults on
-- the runtimepath, so a server configured from this file at startup has no cmd
-- and never starts.

-- rust-analyzer helpers ------------------------------------------------------

local function rust_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })[1]
end

--- Ask rust-analyzer to run cargo check now.
--
-- checkOnSave is off, so cargo diagnostics only appear when asked for.
local function rust_flycheck(bufnr)
  local client = rust_client(bufnr)
  if not client then
    return vim.notify("rust-analyzer is not attached to this buffer", vim.log.levels.WARN)
  end
  client:notify("rust-analyzer/runFlycheck", { textDocument = vim.lsp.util.make_text_document_params(bufnr) })
  vim.notify("rust-analyzer: flycheck requested")
end

--- Restart rust-analyzer for this buffer.
local function rust_restart(bufnr)
  local client = rust_client(bufnr)
  if not client then
    return vim.notify("rust-analyzer is not attached to this buffer", vim.log.levels.WARN)
  end
  vim.notify("rust-analyzer: restarting")
  -- Wait for the client to actually exit before starting a new one. Stopping
  -- is asynchronous, and enabling too early leaves two clients on the buffer.
  client:stop()
  local timer = vim.uv.new_timer()
  local waited = 0
  timer:start(
    100,
    100,
    vim.schedule_wrap(function()
      waited = waited + 100
      if not rust_client(bufnr) or waited > 5000 then
        timer:stop()
        timer:close()
        vim.lsp.enable("rust_analyzer")
        vim.cmd.edit()
      end
    end)
  )
end

-- Keymaps -------------------------------------------------------------------

-- Applied on LspAttach, so every server gets the same set.
local function on_attach(client, bufnr)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
  end

  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("gr", vim.lsp.buf.references, "References")
  map("K", function()
    vim.lsp.buf.hover({ border = "rounded" })
  end, "Hover")
  map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
  map("<leader>cr", vim.lsp.buf.rename, "Rename")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("<leader>cf", function()
    vim.lsp.buf.format({ async = false })
  end, "Format buffer")

  map("<leader>h", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
  end, "Toggle inlay hints")

  if client.name == "rust_analyzer" then
    map("<leader>rb", function()
      rust_restart(bufnr)
    end, "Restart rust-analyzer")
    map("<leader>rc", function()
      rust_flycheck(bufnr)
    end, "Run cargo check")
  end

  -- prettier and autopep8 own these filetypes (lua/plugins/formatting.lua).
  -- Without this the server would also advertise formatting and conform's
  -- lsp_format = "fallback" could pick it.
  if client.name == "ts_ls" or client.name == "pyright" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      on_attach(client, args.buf)
    end
  end,
})
