local Input = require("nui.input")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

-- Utility: Show input (supports multiline)
function M.input(opts, on_submit)
  local is_multiline = opts.multiline or false
  local input = Input({
    position = "50%",
    size = {
      width = 60,
      height = is_multiline and 5 or 10,
    },
    border = {
      style = "rounded",
      text = {
        top = opts.prompt or "Input",
        top_align = "left",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  }, {
    prompt = is_multiline and "" or "> ",
    default_value = opts.default or "",
    on_submit = on_submit,
  })

  input:map("n", "<C-c>", function()
    input:unmount()
    print("❌ Cancelled.")
  end)

  input:mount()
end

function M.multiline_input(opts, on_submit)
  local default = opts.default or ""
  local lines = vim.split(default, "\n")
  local popup = Popup({
    position = "50%",
    size = {
      width = 80,
      height = 10,
    },
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = opts.prompt or "Multiline Input",
        top_align = "left",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
    buf_options = {
      modifiable = true,
      buftype = "acwrite",
    },
  })

  popup:mount()

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

  -- Submit with <leader><CR>
  vim.keymap.set("n", "<leader><CR>", function()
    local result = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
    popup:unmount()
    on_submit(table.concat(result, "\n"))
  end, { buffer = popup.bufnr })

  -- Cancel with <C-c>
  vim.keymap.set("n", "<C-c>", function()
    popup:unmount()
    print("❌ Cancelled.")
  end, { buffer = popup.bufnr })

  -- ESC also cancels
  vim.keymap.set("n", "<Esc>", function()
    popup:unmount()
    print("❌ Cancelled.")
  end, { buffer = popup.bufnr })
end

return M
