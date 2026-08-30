-- Server settings, layered onto LazyVim's nvim-lspconfig spec.
--
-- LazyVim reads opts.servers and calls vim.lsp.config and vim.lsp.enable
-- itself, with the completion capabilities already applied.
--
-- The settings belong in this spec because nvim-lspconfig is lazy-loaded, and
-- it puts the per-server defaults (cmd, root markers, filetypes) on the
-- runtimepath as lsp/<name>.lua. A server configured at startup, before that
-- happens, gets settings but no cmd and never starts.

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

-- Only configure servers whose binary is present. Neovim tries to spawn a
-- server it has been given for every matching buffer, and logs "not installed,
-- missing from PATH, or not executable" each time.
--
-- Each entry includes mason = false. LazyVim calls vim.lsp.enable itself only
-- for servers that are not mason-managed (lazyvim/plugins/lsp/init.lua:257).
-- Left unset, the server goes to mason's ensure_installed instead. These three
-- come from cargo, npm and pip, so mason has nothing to install and the server
-- never starts.
local available = {
  rust_analyzer = "rust-analyzer",
  ts_ls = "typescript-language-server",
  pyright = "pyright-langserver",
}

local servers = {}

if vim.fn.executable(available.rust_analyzer) == 1 then
  servers.rust_analyzer = {
    mason = false,
    settings = {
      ["rust-analyzer"] = {
        imports = {
          group = { enable = false },
          granularity = { enforce = true },
          prefix = "crate",
        },
        cargo = {
          features = "all",
          allTargets = true,
          extraEnv = {
            -- Keeping nvim's analysis out of ./target stops it fighting a
            -- terminal cargo build for the same lock.
            CARGO_TARGET_DIR = cargo_target_dir,
          },
        },
        -- Unset means rust-analyzer's own rustfmt. An override whose binary is
        -- missing is worse than none: leptosfmt without a rustfmt component
        -- echoes its input and exits 0, so formatting silently does nothing.
        rustfmt = rustfmt_override and { overrideCommand = rustfmt_override } or nil,
        procMacro = { enable = true },
        -- cargo check is manual, via <leader>rc - it is slow on a big workspace.
        checkOnSave = false,
        check = { onSave = false },
      },
    },
  }
end

if vim.fn.executable(available.ts_ls) == 1 then
  servers.ts_ls = { mason = false }
end

if vim.fn.executable(available.pyright) == 1 then
  servers.pyright = { mason = false }
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = servers,
  },
}
