local function is_git_tracked(filepath)
  local handle = io.popen("git ls-files --error-unmatch " .. vim.fn.shellescape(filepath) .. " 2>/dev/null")
  if handle == nil then return false end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

local function check_modified_git_buffers()
  local modified_git_buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
      local filepath = vim.api.nvim_buf_get_name(bufnr)
      if filepath ~= "" and is_git_tracked(filepath) then
        table.insert(modified_git_buffers, filepath)
      end
    end
  end

  if #modified_git_buffers > 0 then
    print("Modified Git-tracked files:")
    for _, path in ipairs(modified_git_buffers) do
      print(" - " .. path)
    end
    return true
  end
  return false
end

vim.api.nvim_create_user_command("CheckModifiedGitBuffers", check_modified_git_buffers, {})


vim.keymap.set("n", "<leader>ga", function()
  vim.cmd("!git add %")
end)
return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({})
      vim.keymap.set("n", "<leader>gb", function()
        vim.cmd("Gitsigns blame_line")
      end)
      vim.keymap.set("n", "<leader>gB", function()
        vim.cmd("Gitsigns blame")
      end)
    end,
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({})
      vim.keymap.set("n", "<leader>gd", function()
        vim.cmd("DiffviewOpen")
      end)
      vim.keymap.set("n", "<leader>gc", function()
        vim.cmd("DiffviewClose")
      end)
    end,
  },
  {
    "arthur2klein/convcommit",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "rcarriga/nvim-notify",
    },
    branch = "master",
    config = function()
      local convcommit = require("convcommit")
      convcommit.setup({ validate_input_key = "<CR>" })
      vim.keymap.set("n", "<leader>gg", convcommit.create_commit)
      vim.keymap.set("n", "<leader>gv", convcommit.create_version_tag)
      vim.keymap.set("n", "<leader>gp", function()
        if (not check_modified_git_buffers()) then convcommit.push() end
      end)
      vim.keymap.set("n", "<leader>ga", convcommit.git_add)
    end,
  },
  "kshenoy/vim-signature",
}
