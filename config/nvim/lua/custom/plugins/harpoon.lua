return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set('n', '<leader>na', function()
      harpoon:list():add()
    end)
    vim.keymap.set('n', '<leader>nt', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set('n', '<leader>n1', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<leader>n2', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<leader>n3', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<leader>n4', function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<leader>np', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<leader>nn', function()
      harpoon:list():next()
    end)
  end,
}
