vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 999
vim.opt.guicursor = "n-v-c-sm:block-blinkwait200-blinkon200-blinkoff200,i-ci-ve:ver25-blinkwait200-blinkon200-blinkoff200,r-cr-o:hor20-blinkwait200-blinkon200-blinkoff200"
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "

-- Half-page scroll with cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Start Neovim server for lazygit integration (edit files in parent nvim)
local server_pipe = "/tmp/nvim-server-" .. vim.fn.getpid() .. ".pipe"
vim.fn.serverstart(server_pipe)
vim.env.NVIM_SERVER = server_pipe

-- Toggle file tree with <leader>e
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Telescope keybinds
vim.keymap.set("n", "<leader>p", ":Telescope find_files<CR>")  -- find files (like Ctrl+P)
vim.keymap.set("n", "<leader>f", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")   -- search in files
vim.keymap.set("n", "<leader>b", ":Telescope buffers<CR>")     -- open buffers

-- Buffer navigation
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>")        -- next tab
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")      -- previous tab
vim.keymap.set("n", "<leader>x", function()                      -- close tab
  local buf = vim.api.nvim_get_current_buf()
  -- Don't close nvim-tree with this shortcut
  if vim.bo[buf].filetype == "NvimTree" then return end
  -- Count listed (file) buffers excluding nvim-tree
  local file_bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buflisted
      and vim.bo[b].filetype ~= "NvimTree"
  end, vim.api.nvim_list_bufs())
  if #file_bufs <= 1 then
    -- Last file buffer: close tree if open, then quit
    vim.cmd("NvimTreeClose")
    vim.cmd("bd")
  else
    -- Switch away first so we don't land on nvim-tree
    vim.cmd("BufferLineCycleNext")
    vim.cmd("bd " .. buf)
  end
end)

-- LSP keybinds (set when a language server attaches to a buffer)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = function(desc) return { buffer = ev.buf, desc = desc } end

    -- Go to definition in a new tab
    vim.keymap.set("n", "gd", function()
      vim.cmd("tab split")
      vim.lsp.buf.definition()
    end, opts("Go to definition (new tab)"))

    -- Go to definition in same buffer (if you don't want a new tab)
    vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts("Go to definition (same buffer)"))

    -- Other useful LSP shortcuts
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Find references"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover docs"))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename symbol"))
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts("Type definition"))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("Previous diagnostic"))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("Next diagnostic"))
    vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts("Show diagnostic"))
  end,
})

-- Git UI (opens lazygit in the git root of the current file, or lets you pick a repo)
vim.keymap.set("n", "<leader>gg", function()
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir == "" or file_dir == "." then file_dir = vim.fn.getcwd() end
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(file_dir) .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and git_root then
    require("lazygit").lazygit(git_root)
  else
    local cwd = vim.fn.getcwd()
    local repos = vim.fn.systemlist("find " .. vim.fn.shellescape(cwd) .. " -maxdepth 2 -name .git -type d")
    if #repos == 0 then
      vim.notify("No git repositories found", vim.log.levels.WARN)
      return
    end
    local choices = {}
    for _, repo in ipairs(repos) do
      table.insert(choices, vim.fn.fnamemodify(repo, ":h"))
    end
    vim.ui.select(choices, { prompt = "Select git repo:" }, function(choice)
      if choice then
        require("lazygit").lazygit(choice)
      end
    end)
  end
end)
vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory %<CR>") -- current file history
vim.keymap.set("n", "<leader>gH", ":DiffviewFileHistory<CR>")   -- full repo history
vim.keymap.set("n", "<leader>go", ":DiffviewOpen<CR>")           -- view all changes
vim.keymap.set("n", "<leader>gc", ":DiffviewClose<CR>")          -- close diff view

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          gitsigns = true,
          nvimtree = true,
          telescope = { enabled = true },
          bufferline = true,
          flash = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function open_lazygit_for_node()
        local api = require("nvim-tree.api")
        local node = api.tree.get_node_under_cursor()
        if not node then return end

        -- Get the path (use the node's path, or parent dir for files)
        local dir = node.absolute_path
        if node.type ~= "directory" then
          dir = vim.fn.fnamemodify(dir, ":h")
        end

        -- Find the git root from this path
        local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
        if vim.v.shell_error ~= 0 or not git_root then
          vim.notify("Not a git repository", vim.log.levels.WARN)
          return
        end

        require("lazygit").lazygit(git_root)
      end

      require("nvim-tree").setup({
        sync_root_with_cwd = false,
        respect_buf_cwd = false,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          width = 30,
          number = true,
          relativenumber = false,
          adaptive_size = true,
        },
        renderer = {
          highlight_git = "all",
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            git_placement = "after",
          },
        },
        git = {
          enable = true,
          ignore = false,
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          local opts = function(desc) return { buffer = bufnr, desc = desc, noremap = true, silent = true } end
          -- l = drill into folder, h = go back up
          vim.keymap.set("n", "l", api.tree.change_root_to_node, opts("CD into folder"))
          vim.keymap.set("n", "h", api.tree.change_root_to_parent, opts("Go up to parent"))
          -- gl = open lazygit for repo
          vim.keymap.set("n", "gl", open_lazygit_for_node, opts("Open lazygit for repo"))
          -- Remove nvim-tree's default "s" so flash.nvim works in the tree
          vim.keymap.del("n", "s", { buffer = bufnr })
          vim.keymap.del("n", "S", { buffer = bufnr })
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git", "--exclude", "node_modules" },
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "]c", gs.next_hunk, "Next hunk")
          map("n", "[c", gs.prev_hunk, "Previous hunk")

          -- Actions
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>ga", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>gu", gs.undo_stage_hunk, "Unstage hunk")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>gA", gs.stage_buffer, "Stage entire file")
          map("n", "<leader>gR", gs.reset_buffer, "Reset entire file")
          map("n", "<leader>gb", gs.blame_line, "Blame line")
          map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, "Blame line (full)")
          map("n", "<leader>gd", gs.diffthis, "Diff against index")
        end,
      })
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup()
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          offsets = {
            { filetype = "NvimTree", text = "File Explorer", text_align = "center" },
          },
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
        },
      })
    end,
  },

  -- LSP: server configs (provides filetypes/cmd/root_dir for vim.lsp.enable)
  { "neovim/nvim-lspconfig" },

  -- LSP: Mason (auto-install language servers)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = { mode = "search" },
      modes = { search = { enabled = true } },
      label = { uppercase = false },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",                             -- TypeScript/JavaScript
          "pyright",                           -- Python
          "gopls",                             -- Go
          "zls",                               -- Zig
          "dockerls",                          -- Dockerfile
          "docker_compose_language_service",   -- Docker Compose
          "yamlls",                            -- YAML
          -- Note: dartls is not installed via Mason; it comes with the Dart SDK
        },
      })
    end,
  },
})

-- Enable LSP servers (Neovim 0.11+ native API)
vim.lsp.enable({
  "ts_ls",                             -- TypeScript/JavaScript
  "pyright",                           -- Python
  "gopls",                             -- Go
  "zls",                               -- Zig
  "dartls",                            -- Dart/Flutter
  "dockerls",                          -- Dockerfile
  "docker_compose_language_service",   -- Docker Compose
  "yamlls",                            -- YAML
})

-- Load custom multi-repo git status plugin
require("multi-repo-git").setup()
