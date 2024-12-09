local wk = require 'which-key'

-- Function to close the current buffer and swap to another if available
function BuffClose()
  local current_buf = vim.api.nvim_get_current_buf()
  local next_buf = vim.fn.bufnr '#' -- Find the alternate buffer (# refers to the last-used buffer)

  if next_buf > 0 and vim.api.nvim_buf_is_valid(next_buf) then
    -- Switch to the alternate buffer before closing
    vim.api.nvim_set_current_buf(next_buf)
  else
    -- No alternate buffer; create a new buffer
    vim.cmd 'enew'
  end

  -- Close the current buffer
  vim.cmd('bdelete ' .. current_buf)
end

local last_buffer = nil

-- Track the last active buffer before leaving it
vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    last_buffer = vim.api.nvim_get_current_buf()
  end,
})

-- Run buffClose logic when the current buffer is deleted
vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(args)
    if args.buf == last_buffer then
      BuffClose()
    end
  end,
})

wk.add {
  -- Group for buffers
  { '<leader>b', group = 'buffers' }, -- buffer group

  { '<leader>bc', ':lua BuffClose()<CR>', desc = 'Force close buffer' },
  { '<leader>bC', ':%bd|e#|bd#<CR>', desc = 'Close all other buffers' },
  { '<leader>bd', ':bd<CR>', desc = 'Close current buffer' },
  { '<leader>bl', '<cmd>Telescope buffers<cr>', desc = 'List buffers with Telescope' }, -- Using Telescope to list buffers
  { '<leader>bn', ':bnext<CR>', desc = 'Next buffer' },
  { '<leader>bp', ':bprevious<CR>', desc = 'Previous buffer' },

  -- Mappings for navigating between buffers
  { '[b', ':bprevious<CR>', desc = 'Previous buffer' },
  { ']b', ':bnext<CR>', desc = 'Next buffer' },
}
