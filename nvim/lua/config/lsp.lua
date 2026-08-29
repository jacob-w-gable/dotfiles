-- Language server configuration.
--
-- Uses vim.lsp.config / vim.lsp.enable (Neovim 0.11+) rather than the
-- require("lspconfig").X.setup() "framework", which nvim-lspconfig deprecates
-- on 0.11 and which fired a deprecation warning with a backtrace at startup.
-- It also meant two systems were creating clients: LazyVim drives LSP through
-- vim.lsp.config, so servers set up the old way got different capabilities and
-- a separate on_attach chain.
--
-- The server settings themselves live in lua/plugins/lspconfig.lua, layered
-- onto LazyVim's spec -- nvim-lspconfig is lazy-loaded, so a server configured
-- from here at startup would have no cmd and never start. This file is the
-- keymaps and the rust-analyzer helpers they call.

-- rust-analyzer helpers ------------------------------------------------------

local function rust_client(bufnr)
  return vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })[1]
end

--- Ask rust-analyzer to run cargo check now.
--
-- checkOnSave is off below, so diagnostics from cargo only appear when asked.
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
  -- Wait for the client to actually exit before starting a new one; stopping
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

-- One place, applied on LspAttach, rather than the same ~60 lines pasted into
-- each server's on_attach.
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

  -- Formatting comes from conform (see lua/plugins/formatting.lua) or, with no
  -- formatter registered for the filetype, from the LSP itself. Turning it off
  -- for these two keeps prettier authoritative for JS/TS and Python.
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
