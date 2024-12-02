return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    -- Key mappings
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end)
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu()
    end)

    vim.keymap.set('n', '<C-h>', function()
      harpoon.ui:select_menu_item(1)
    end)
    vim.keymap.set('n', '<C-t>', function()
      harpoon.ui:select_menu_item(2)
    end)
    vim.keymap.set('n', '<C-n>', function()
      harpoon.ui:select_menu_item(3)
    end)
    vim.keymap.set('n', '<C-s>', function()
      harpoon.ui:select_menu_item(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<C-S-P>', function()
      harpoon:list():prev()()
    end)
    vim.keymap.set('n', '<C-S-N>', function()
      harpoon:list():next()
    end)
  end,
}
