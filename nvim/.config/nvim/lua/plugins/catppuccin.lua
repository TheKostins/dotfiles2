return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = true,
        float = {
          transparent = true,
          solid = false,
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = true,
          which_key = true,
          notify = true,
          mini = true,
          noice = true,
          mason = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
