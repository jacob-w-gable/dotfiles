return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local section_left = ""
    local section_right = ""
    local component_left = ""
    local component_right = ""
    local theme = "auto"
    local icons_enabled = true
    local clock = "  %H:%M"

    if vim.g.no_glyphs then
      section_left = ""
      section_right = ""
      component_left = "|"
      component_right = "|"
      theme = "16color"
      icons_enabled = false
      clock = "%H:%M"
    end

    -- Branch diff stat for the whole repo: everything since the fork from origin/HEAD
    -- (or main), committed, staged, unstaged and untracked, like the gdstat zsh
    -- function. It runs async on a throwaway index, so the real one is untouched,
    -- and the statusline only reads the cached result.
    local branch_stat = nil
    local branch_stat_script = [[
      git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
      base=$(git symbolic-ref -q --short refs/remotes/origin/HEAD || echo main)
      mb=$(git merge-base "$base" HEAD 2>/dev/null) || exit 0
      tmp=$(mktemp)
      cp "$(git rev-parse --path-format=absolute --git-path index)" "$tmp"
      GIT_INDEX_FILE=$tmp git add -N :/ 2>/dev/null
      GIT_INDEX_FILE=$tmp git diff --shortstat "$mb"
      rm -f "$tmp"
    ]]
    local function refresh_branch_stat()
      local opts = { cwd = vim.fn.getcwd(), text = true }
      vim.system({ "sh", "-c", branch_stat_script }, opts, function(result)
        local out = result.stdout or ""
        local files = out:match("(%d+) files?")
        local ins = out:match("(%d+) insertion") or "0"
        local del = out:match("(%d+) deletion") or "0"
        branch_stat = files and { files = files, ins = ins, del = del } or nil
      end)
    end
    vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained", "DirChanged" }, {
      group = vim.api.nvim_create_augroup("lualine_branch_stat", { clear = true }),
      callback = refresh_branch_stat,
    })
    -- Edits made outside nvim (Claude, another shell) land without an event here.
    vim.fn.timer_start(10000, refresh_branch_stat, { ["repeat"] = -1 })
    refresh_branch_stat()
    local function has_branch_stat()
      return branch_stat ~= nil
    end
    -- A color function, so the segment follows a colorscheme switch.
    local function fg_of(group)
      return function()
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        return hl.fg and { fg = string.format("#%06x", hl.fg), gui = "bold" } or nil
      end
    end

    require("lualine").setup({
      options = {
        icons_enabled = icons_enabled,
        theme = theme,
        section_separators = { left = section_left, right = section_right },
        component_separators = { left = component_left, right = component_right },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", file_status = true, newfile_status = true, path = 1 } },
        lualine_x = {
          {
            function()
              return branch_stat.files .. " files"
            end,
            cond = has_branch_stat,
            color = fg_of("Changed"),
            separator = "",
            padding = { left = 1, right = 0 },
          },
          {
            function()
              return "+" .. branch_stat.ins
            end,
            cond = has_branch_stat,
            color = fg_of("Added"),
            separator = "",
            padding = { left = 1, right = 0 },
          },
          {
            function()
              return "-" .. branch_stat.del
            end,
            cond = has_branch_stat,
            color = fg_of("Removed"),
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress", "location" },
        lualine_z = { { "datetime", style = clock } },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { "mason", "neo-tree", "trouble" },
    })
  end,
}
