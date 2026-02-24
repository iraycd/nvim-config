-- Custom plugin: Multi-repo git status for nvim-tree
-- Scans subdirectories for .git repos and marks folders with change counts

local M = {}

local ns = vim.api.nvim_create_namespace("multi_repo_git")

-- Highlight groups
vim.api.nvim_set_hl(0, "MultiRepoGitDirty", { fg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "MultiRepoGitClean", { fg = "#a6e3a1" })
vim.api.nvim_set_hl(0, "MultiRepoGitCount", { fg = "#fab387", bold = true })

local repo_status = {}
local timer = nil

function M.scan_repos()
  local cwd = vim.fn.getcwd()
  repo_status = {}

  local git_dirs = vim.fn.systemlist("find " .. vim.fn.shellescape(cwd) .. " -maxdepth 2 -name .git -type d 2>/dev/null")

  for _, git_dir in ipairs(git_dirs) do
    local repo_dir = vim.fn.fnamemodify(git_dir, ":h")
    local repo_name = vim.fn.fnamemodify(repo_dir, ":t")
    local status = vim.fn.systemlist("git -C " .. vim.fn.shellescape(repo_dir) .. " status --porcelain 2>/dev/null")
    repo_status[repo_name] = {
      path = repo_dir,
      changes = #status,
      dirty = #status > 0,
    }
  end
end

function M.update_tree()
  local tree_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local ok, ft = pcall(function() return vim.bo[buf].filetype end)
    if ok and ft == "NvimTree" then
      tree_buf = buf
      break
    end
  end

  if not tree_buf or not vim.api.nvim_buf_is_valid(tree_buf) then return end

  vim.api.nvim_buf_clear_namespace(tree_buf, ns, 0, -1)

  local ok, lines = pcall(vim.api.nvim_buf_get_lines, tree_buf, 0, -1, false)
  if not ok then return end

  for i, line in ipairs(lines) do
    for repo_name, info in pairs(repo_status) do
      -- Strip ANSI/icon chars and match folder name
      local clean = line:gsub("[%z\1-\31\127]", "")
      if clean:match("%f[%w]" .. vim.pesc(repo_name) .. "%f[%W]") then
        local mark_text, mark_hl
        if info.dirty then
          mark_text = " [" .. info.changes .. " changes]"
          mark_hl = "MultiRepoGitCount"
        else
          mark_text = " [clean]"
          mark_hl = "MultiRepoGitClean"
        end

        pcall(vim.api.nvim_buf_set_extmark, tree_buf, ns, i - 1, 0, {
          virt_text = { { mark_text, mark_hl } },
          virt_text_pos = "eol",
        })
      end
    end
  end
end

function M.refresh()
  M.scan_repos()
  M.update_tree()
end

function M.start_timer()
  if timer then return end
  timer = vim.uv.new_timer()
  -- Redraw extmarks every 500ms, rescan git every 5s
  local tick = 0
  timer:start(500, 500, vim.schedule_wrap(function()
    tick = tick + 1
    if tick % 10 == 0 then
      M.scan_repos()
    end
    M.update_tree()
  end))
end

function M.stop_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

function M.setup()
  -- Initial scan
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
      M.refresh()
      M.start_timer()
    end,
  })

  -- Re-scan git on file save or focus
  vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
    callback = function()
      M.scan_repos()
    end,
  })

  -- Catch nvim-tree redraws via its own events
  local ok, api = pcall(require, "nvim-tree.api")
  if ok then
    api.events.subscribe(api.events.Event.TreeRendered, function()
      vim.defer_fn(function()
        M.update_tree()
      end, 50)
    end)
  end

  -- Stop timer when nvim-tree closes
  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function()
      if vim.bo.filetype == "NvimTree" then
        M.stop_timer()
      end
    end,
  })

  -- Manual refresh
  vim.keymap.set("n", "<leader>gm", function()
    M.refresh()
    vim.notify("Git status refreshed", vim.log.levels.INFO)
  end)
end

return M
