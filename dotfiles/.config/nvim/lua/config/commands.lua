local This = {}

-- Strip any junk before the first { or [ and after the last } or ]. Useful when
-- copying JSON from a browser that grabs stray characters around the payload.
local function json_trim(s)
  return s:match('[%[{].*[%]}]') or s
end

function This.setup()
  -- View clipboard JSON formatted in a scratch buffer
  vim.api.nvim_create_user_command('JsonView', function()
    local raw = json_trim(vim.fn.getreg('+'))
    if raw == '' then
      vim.notify('Clipboard is empty', vim.log.levels.WARN)
      return
    end

    local formatted = vim.fn.systemlist({ 'jq', '.' }, raw)
    if vim.v.shell_error ~= 0 then
      vim.notify('Invalid JSON:\n' .. table.concat(formatted, '\n'), vim.log.levels.ERROR)
      return
    end

    vim.cmd('enew')
    vim.bo.buftype = 'nofile'
    vim.bo.bufhidden = 'wipe'
    vim.bo.filetype = 'json'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
  end, { desc = 'View clipboard JSON formatted' })

  -- Format the current buffer (or a range) in place with jq
  vim.api.nvim_create_user_command('JsonFormat', function(opts)
    local range = opts.range > 0 and (opts.line1 .. ',' .. opts.line2) or '%'
    vim.cmd(range .. '!jq .')
    if vim.v.shell_error ~= 0 then
      vim.notify('jq failed: invalid JSON', vim.log.levels.ERROR)
      vim.cmd('undo')
    end
  end, { range = true, desc = 'Format JSON in place with jq' })
end

return This
