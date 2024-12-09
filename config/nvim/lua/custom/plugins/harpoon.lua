return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    local wk = require 'which-key'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    wk.add {
      { '<leader>n', group = 'harpoon' }, -- group for Harpoon commands
      {
        '<leader>na',
        function()
          harpoon:list():add()
        end,
        desc = 'Add current file to Harpoon',
      },
      {
        '<leader>nt',
        function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Toggle Harpoon menu',
      },
      {
        '<leader>n1',
        function()
          harpoon:list():select(1)
        end,
        desc = 'Select file 1 in Harpoon',
      },
      {
        '<leader>n2',
        function()
          harpoon:list():select(2)
        end,
        desc = 'Select file 2 in Harpoon',
      },
      {
        '<leader>n3',
        function()
          harpoon:list():select(3)
        end,
        desc = 'Select file 3 in Harpoon',
      },
      {
        '<leader>n4',
        function()
          harpoon:list():select(4)
        end,
        desc = 'Select file 4 in Harpoon',
      },
      {
        '<leader>np',
        function()
          harpoon:list():prev()
        end,
        desc = 'Previous file in Harpoon list',
      },
      {
        '<leader>nn',
        function()
          harpoon:list():next()
        end,
        desc = 'Next file in Harpoon list',
      },
    }
  end,
}
