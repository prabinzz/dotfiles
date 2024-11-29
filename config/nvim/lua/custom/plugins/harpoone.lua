return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  event = 'BufRead',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- Harpoon setup
    local harpoon = require 'harpoon'
    -- REQUIRED: Harpoon setup
    harpoon.setup()

    -- Key mappings for Harpoon
    vim.keymap.set('n', '<leader>ha', function()
      harpoon.mark.add_file()
    end, { noremap = true, silent = true })
    vim.keymap.set('n', 'ht', function()
      harpoon.ui.toggle_quick_menu()
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>1', function()
      harpoon.ui.nav_file(1)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>2', function()
      harpoon.ui.nav_file(2)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>3', function()
      harpoon.ui.nav_file(3)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>4', function()
      harpoon.ui.nav_file(4)
    end, { noremap = true, silent = true })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<C-p>', function()
      harpoon.ui.nav_prev()
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<C-n>', function()
      harpoon.ui.nav_next()
    end, { noremap = true, silent = true })
  end,
}
