-- Arabic language tools
--
-- Keymaps:
--   <leader>at    Toggle arabic mode
--   <leader>ac    Arabizi

-- toggle Arabic keymap
vim.keymap.set("n", "<leader>at", function()
  vim.cmd("set arabic!")
end, { desc = "Toggle Arabic mode" })

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

-- token -> list of {arabic_char, note}. First entry per token is the default guess.
local map = {
  { "kh", { { "خ" } } },
  { "gh", { { "غ" } } },
  { "ch", { { "ش" } } },
  { "sh", { { "ش" } } },
  { "th", { { "ث" }, { "ذ", "th as in 'this'" } } },
  { "aa", { { "ا" } } },
  { "ou", { { "و" } } },
  { "a", { { "ا" } } },
  { "b", { { "ب" } } },
  { "t", { { "ت" }, { "ط", "emphatic t" } } },
  { "j", { { "ج" } } },
  { "7", { { "ح" } } },
  { "d", { { "د" }, { "ض", "emphatic d" } } },
  { "r", { { "ر" } } },
  { "z", { { "ز" } } },
  { "s", { { "س" }, { "ص", "emphatic s" } } },
  { "9", { { "ق" } } },
  { "3", { { "ع" } } },
  { "f", { { "ف" } } },
  { "m", { { "م" } } },
  { "n", { { "ن" } } },
  { "h", { { "ه" }, { "ح", "throaty h" } } },
  { "w", { { "و" } } },
  { "y", { { "ي" } } },
  { "2", { { "ء" } } },
  { "5", { { "خ" } } },
}

local function tokenize(word)
  local tokens, i = {}, 1
  while i <= #word do
    local matched = false
    for _, pair in ipairs(map) do
      local tok, candidates = pair[1], pair[2]
      if word:sub(i, i + #tok - 1) == tok then
        table.insert(tokens, { candidates = candidates })
        i = i + #tok
        matched = true
        break
      end
    end
    if not matched then
      table.insert(tokens, { candidates = { { word:sub(i, i) } } })
      i = i + 1
    end
  end
  return tokens
end

local function render(tokens, flip_idx, flip_choice)
  local out = ""
  for idx, tok in ipairs(tokens) do
    local choice = (idx == flip_idx) and flip_choice or 1
    out = out .. tok.candidates[choice][1]
  end
  return out
end

-- default rendering + one variant per ambiguous letter (kept linear, not combinatorial)
local function generate_candidates(word)
  local tokens = tokenize(word)
  local results = { { text = render(tokens), note = "default" } }
  for idx, tok in ipairs(tokens) do
    for c = 2, #tok.candidates do
      table.insert(results, {
        text = render(tokens, idx, c),
        note = tok.candidates[c][2] or "variant",
      })
    end
  end
  return results
end

local function replace_cword(text)
  vim.cmd('normal! "_diw')
  vim.api.nvim_put({ text }, "c", false, true)
end

function arabizi_picker()
  vim.cmd('normal! "vy')
  local word = vim.fn.getreg("v")
  if word == "" then
    return
  end

  pickers
    .new({}, {
      prompt_title = "Arabizi: " .. word,
      finder = finders.new_table({
        results = generate_candidates(word),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.text .. "   (" .. entry.note .. ")",
            ordinal = entry.text .. entry.note,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          replace_cword(selection.value.text)
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set("v", "<leader>ac", arabizi_picker, { desc = "Arabizi transliteration picker" })

-- add to arabizi.lua

local reverse_map = {
  ["ا"] = "a",
  ["ب"] = "b",
  ["ت"] = "t",
  ["ث"] = "th",
  ["ج"] = "j",
  ["ح"] = "7",
  ["خ"] = "kh",
  ["د"] = "d",
  ["ذ"] = "th",
  ["ر"] = "r",
  ["ز"] = "z",
  ["س"] = "s",
  ["ش"] = "ch",
  ["ص"] = "s",
  ["ض"] = "d",
  ["ط"] = "t",
  ["ظ"] = "th",
  ["ع"] = "3",
  ["غ"] = "gh",
  ["ف"] = "f",
  ["ق"] = "9",
  ["ك"] = "k",
  ["ل"] = "l",
  ["م"] = "m",
  ["ن"] = "n",
  ["ه"] = "h",
  ["و"] = "w",
  ["ي"] = "y",
  ["ء"] = "2",
  ["ة"] = "a",
}

local function arabic_to_latin(word)
  local chars = vim.fn.split(word, "\\zs")
  local out = {}
  for _, ch in ipairs(chars) do
    table.insert(out, reverse_map[ch] or ch)
    table.insert(out, "*")
  end
  return table.concat(out)
end

function preview_reverse()
  -- word-under-cursor via <cword> is unreliable for Arabic since 'iskeyword'
  -- usually doesn't include Arabic codepoints, so grab the visual selection instead
  vim.cmd('normal! "vy')
  local word = vim.fn.getreg("v")
  local latin = arabic_to_latin(word)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { latin })
  vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = math.max(10, #latin + 2),
    height = 1,
    style = "minimal",
    border = "rounded",
  })
end

vim.keymap.set("v", "<leader>ar", preview_reverse, { desc = "Arabic -> Arabizi" })

return {}
