-- Fuzzy finder (telescope) with DAP, symbols and notify pickers.
--
-- Keymaps:
--   <leader>ff   find files          <leader>fF   find files in buffer dir
--   <leader>fg   live grep           <leader>fG   live grep in buffer dir
--   <leader>fr   LSP references      <leader>ft   treesitter symbols
--   <leader>fa   diagnostics         <leader>fb   git branches
--   <leader>fc   git commits         <leader>fC   git commits (buffer)
--   <leader>f<leader>  git status
--   <leader>fh   command history     <leader>fm   marks
--   <leader>fj   jumplist            <leader>fs   spelling suggestions
--   <leader>fp   list pickers        <leader>fR   resume last picker
--   <leader>fn   notifications       <leader>fy   clipboard (neoclip)
--   <leader>fq   macro history (macroscope)
--   <leader>fe   emoji/kaomoji/gitmoji   <leader>fM  math/latex symbols
--   <leader>fo   julia/nerd symbols
--   <leader>fda/fdc/fdb/fdv/fdf   DAP commands / configs / breakpoints /
--                                 variables / frames
--
-- In visual mode, ff/fF/fg/fG/ft open the same picker pre-filled with the
-- selected text as the prompt filter.
--
-- Inside a picker (insert mode):
--   <C-g>            open in the previous tabpage
--   <C-"> / <C-v>    open in a horizontal / vertical split
--   <C-j> / <C-k>    next / previous result
--   <C-e> / <C-r>    git merge / rebase the selected branch
--   <C-h> / <C-l>    git checkout -- (ours) / --theirs the selected file

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "nvim-telescope/telescope-symbols.nvim",
    },
    config = function()
      require("telescope").load_extension("dap")
      require("telescope").load_extension("notify")
      local builtin = require("telescope.builtin")

      -- Yank the current visual selection (via a scratch register so the
      -- unnamed register is left untouched) and collapse it to a single
      -- line so it can seed a picker prompt. Called from visual-mode maps;
      -- the yank also exits visual mode before the picker opens.
      local function visual_selection()
        local save, save_type = vim.fn.getreg("z"), vim.fn.getregtype("z")
        vim.cmd('noautocmd silent! normal! "zy')
        local text = vim.fn.getreg("z")
        vim.fn.setreg("z", save, save_type)
        return (text or ""):gsub("[\n\r]", " "):gsub("%s+$", "")
      end

      -- Wrap a picker so it opens pre-filled with the visual selection.
      local function seeded(picker, opts)
        return function()
          picker(vim.tbl_extend("force", opts or {}, { default_text = visual_selection() }))
        end
      end

      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local utils = require("telescope.utils")
      local telescope_dap = require("telescope").extensions.dap
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fF", function() builtin.find_files({ cwd = utils.buffer_dir() }) end, { desc = "Find files in buffer dir" })
      vim.keymap.set("n", "<leader>fa", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>fC", builtin.git_bcommits, { desc = "Git commits (buffer)" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fG", function() builtin.live_grep({ cwd = utils.buffer_dir() }) end, { desc = "Live grep in buffer dir" })
      vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Treesitter symbols" })
      vim.keymap.set("n", "<leader>f<leader>", builtin.git_status, { desc = "Git status" })
      vim.keymap.set("n", "<leader>fb", builtin.git_branches, { desc = "Git branches" })
      vim.keymap.set("n", "<leader>fh", builtin.command_history, { desc = "Command history" })
      vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Marks" })
      vim.keymap.set("n", "<leader>fj", builtin.jumplist, { desc = "Jumplist" })
      vim.keymap.set("n", "<leader>fs", builtin.spell_suggest, { desc = "Spelling suggestions" })
      vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "LSP references" })
      vim.keymap.set("n", "<leader>fR", builtin.resume, { desc = "Resume last picker" })

      -- Visual mode: same maps, pre-filled with the selected text.
      vim.keymap.set("x", "<leader>ff", seeded(builtin.find_files), { desc = "Find files (selection)" })
      vim.keymap.set("x", "<leader>fF", function() builtin.find_files({ cwd = utils.buffer_dir(), default_text = visual_selection() }) end, { desc = "Find files in buffer dir (selection)" })
      vim.keymap.set("x", "<leader>fg", seeded(builtin.live_grep), { desc = "Live grep (selection)" })
      vim.keymap.set("x", "<leader>fG", function() builtin.live_grep({ cwd = utils.buffer_dir(), default_text = visual_selection() }) end, { desc = "Live grep in buffer dir (selection)" })
      vim.keymap.set("x", "<leader>ft", seeded(builtin.treesitter), { desc = "Treesitter symbols (selection)" })
      vim.keymap.set("n", "<leader>fp", builtin.pickers, { desc = "List pickers" })
      vim.keymap.set("n", "<leader>fn", require("telescope").extensions.notify.notify, { desc = "Notifications" })
      -- vim.keymap.set("n", "<leader>fy", builtin.registers, {})

      vim.keymap.set("n", "<leader>fq", require("telescope").extensions.macroscope.default, { desc = "Macro history" })
      vim.keymap.set("n", "<leader>fy", require("telescope").extensions.neoclip.default, { desc = "Clipboard history (neoclip)" })
      vim.keymap.set("n", "<leader>fe", function()
        builtin.symbols({ sources = { "emoji", "kaomoji", "gitmoji" } })
      end, { desc = "Emoji / kaomoji / gitmoji" })
      vim.keymap.set("n", "<leader>fM", function()
        builtin.symbols({ sources = { "math", "latex" } })
      end, { desc = "Math / latex symbols" })
      vim.keymap.set("n", "<leader>fo", function()
        builtin.symbols({ sources = { "julia", "nerd" } })
      end, { desc = "Julia / nerd symbols" })

      vim.keymap.set("n", "<leader>fda", telescope_dap.commands, { desc = "DAP commands" })
      vim.keymap.set("n", "<leader>fdc", telescope_dap.configurations, { desc = "DAP configurations" })
      vim.keymap.set("n", "<leader>fdb", telescope_dap.list_breakpoints, { desc = "DAP breakpoints" })
      vim.keymap.set("n", "<leader>fdv", telescope_dap.variables, { desc = "DAP variables" })
      vim.keymap.set("n", "<leader>fdf", telescope_dap.frames, { desc = "DAP frames" })

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-g>"] = actions.file_edit,
              ["<C-\">"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-e>"] = function(prompt_bufnr)
                actions.git_merge_branch(prompt_bufnr)
                vim.cmd("checktime")
              end,
              ["<C-r>"] = function(prompt_bufn)
                actions.git_rebase_branch(prompt_bufn)
                vim.cmd("checktime")
              end,
              ["<C-h>"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                if selection == nil then
                  utils.__warn_no_selection("git_rollback")
                  return
                end
                utils.get_os_command_output(
                  { "git", "checkout", "--", selection.value },
                  current_picker.cwd
                )
                current_picker:delete_selection(function()
                  local _, ret, _ = utils.get_os_command_output(
                    { "git", "rev-parse", "--verify", "MERGE_HEAD" },
                    current_picker.cwd
                  )
                  return not (ret == 0)
                end)
                vim.cmd("checktime")
              end,
              ["<C-l>"] = function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                if selection == nil then
                  utils.__warn_no_selection("git_checkout_theirs")
                  return
                end
                utils.get_os_command_output(
                  { "git", "checkout", "--theirs", selection.value },
                  current_picker.cwd
                )
                vim.cmd("checktime")
              end,
            },
          },
        },
        pickers = {
          git_status = {
            theme = "dropdown",
          },
          find_files = {
            hidden = true,
            file_ignore_patterns = { ".git/" },
          },
        },
      })
    end,
  },
}
