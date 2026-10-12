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

-- Root of rust-analyzer's build artifacts. Each workspace gets its own
-- subdirectory below it, named by target_dir_for.
local cargo_target_root = machine.cargo_target_dir or (vim.env.HOME .. "/.cargo/nvim-target")

-- Cargo leaves a package's path out of its fingerprint, so two checkouts of the
-- same crate - a worktree and the branch it was made from - share one slot in a
-- shared target directory. They take turns invalidating each other, and when the
-- second checkout's files are older than the artifacts built from the first,
-- which is what git worktree add produces, cargo calls them fresh and reuses the
-- other checkout's output. rust-analyzer then reports the other branch's
-- diagnostics.
--
-- Keying the directory on the workspace root gives each checkout its own slot.
-- The cost is that registry dependencies are built once per workspace instead of
-- once in total.
local function target_dir_for(root)
  if not root then
    return cargo_target_root
  end
  root = vim.fs.normalize(root)
  local name = vim.fn.fnamemodify(root, ":t"):gsub("[^%w._-]", "_")
  return ("%s/%s-%s"):format(cargo_target_root, name, vim.fn.sha256(root):sub(1, 12))
end

local rustfmt_override = machine.rustfmt_override
if rustfmt_override and vim.fn.executable(rustfmt_override[1]) == 0 then
  vim.notify(
    ("rustfmt_override %q is not installed; using rust-analyzer's rustfmt"):format(rustfmt_override[1]),
    vim.log.levels.WARN
  )
  rustfmt_override = nil
end

-- Lines of Cargo.lock read before giving up on finding the leptos entry. The
-- largest lockfile here is around 9000 lines.
local LOCKFILE_SCAN_LIMIT = 30000

--- True when the workspace's Cargo.lock includes the leptos crate.
local function uses_leptos(root)
  if not root then
    return false
  end
  local lock = io.open(vim.fs.normalize(root) .. "/Cargo.lock", "r")
  if not lock then
    return false
  end
  local found = false
  local scanned = 0
  for line in lock:lines() do
    scanned = scanned + 1
    if line == 'name = "leptos"' then
      found = true
      break
    end
    if scanned >= LOCKFILE_SCAN_LIMIT then
      break
    end
  end
  lock:close()
  return found
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
    -- root_dir is resolved before this runs, and vim.lsp deep-copies the config
    -- for every client, so this touches one client's settings and not the shared
    -- spec. Edit the table in place rather than replacing it: the client kept a
    -- reference to it when it was created.
    before_init = function(_, config)
      local settings = config.settings["rust-analyzer"]
      settings.cargo.extraEnv.CARGO_TARGET_DIR = target_dir_for(config.root_dir)
      -- leptosfmt only has something to do where the view! macro is, and it
      -- breaks every other workspace: rust-analyzer sends the buffer to an
      -- overrideCommand on stdin without the crate's edition, so the rustfmt
      -- behind leptosfmt parses as edition 2015 and rejects `async fn`. Its
      -- exit code is still 0 and its output is the unchanged input, so the
      -- save looks like it formatted. rust-analyzer's own rustfmt passes
      -- --edition from Cargo.toml and needs no such workaround.
      if rustfmt_override and uses_leptos(config.root_dir) then
        settings.rustfmt = { overrideCommand = rustfmt_override }
      end
    end,
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
            -- terminal cargo build for the same lock. before_init narrows this
            -- to the workspace's own subdirectory; the root is the fallback for
            -- a client that starts without a root_dir.
            CARGO_TARGET_DIR = cargo_target_root,
          },
        },
        -- Unset means rust-analyzer's own rustfmt. before_init adds an
        -- overrideCommand for the workspaces that use leptos.
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
