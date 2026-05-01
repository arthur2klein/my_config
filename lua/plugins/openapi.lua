local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "OpenApiDoc" })
end

local function resolve_cmd()
  if vim.fn.executable("widdershins") == 1 then
    return { "widdershins" }
  elseif vim.fn.executable("npx") == 1 then
    return { "npx", "-y", "widdershins" }
  end
  return nil
end

local function generate_doc(opts)
  local input = opts.fargs[1]
      and vim.fn.fnamemodify(opts.fargs[1], ":p")
      or vim.api.nvim_buf_get_name(0)

  if input == "" or not (vim.uv or vim.loop).fs_stat(input) then
    notify("Input spec not found: " .. tostring(input), vim.log.levels.ERROR)
    return
  end

  local output = vim.fn.fnamemodify(input, ":r") .. ".md"
  if (vim.uv or vim.loop).fs_stat(output) and not opts.bang then
    if vim.fn.confirm(output .. " exists. Overwrite?", "&Yes\n&No", 2) ~= 1 then
      return
    end
  end

  local base = resolve_cmd()
  if not base then
    notify("widdershins not found. Install with `npm i -g widdershins` (or ensure npx is on PATH).",
      vim.log.levels.ERROR)
    return
  end

  local argv = vim.list_extend(vim.deepcopy(base), {
    "--httpsnippet",
    "--language_tabs", "shell:Shell:curl",
    "--language_tabs", "javascript:JavaScript:fetch",
    "--omitHeader",
    "--summary",
    "--resolve",
    input,
    "-o", output,
  })

  notify("Generating " .. vim.fn.fnamemodify(output, ":t") .. "…")

  vim.system(argv, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 and (vim.uv or vim.loop).fs_stat(output) then
        notify("Wrote " .. output)
        vim.cmd("vsplit " .. vim.fn.fnameescape(output))
      else
        local stderr = (obj.stderr or ""):sub(1, 1000)
        notify("widdershins failed (exit " .. tostring(obj.code) .. "):\n" .. stderr,
          vim.log.levels.ERROR)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("OpenApiDoc", generate_doc, {
  nargs = "?",
  bang = true,
  complete = "file",
  desc = "Generate Markdown (curl + fetch) from an OpenAPI/Swagger spec",
})

return {}
