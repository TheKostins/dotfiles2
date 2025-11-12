return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",

    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- ── Setup ────────────────────────────────────────────────────────────────
      require("rainbow-delimiters.setup")({
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })

      -- ── Gruvbox Dark Palette ────────────────────────────────────────────────
      local colors = {
        red = "#FB4934",
        yellow = "#FABD2F",
        blue = "#83A598",
        orange = "#FE8019",
        green = "#B8BB26",
        violet = "#D3869B",
        cyan = "#8EC07C",
      }

      -- ── Apply highlight groups (link-safe) ───────────────────────────────────
      vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.red })
      vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = colors.yellow })
      vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = colors.green })
      vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = colors.violet })
      vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = colors.cyan })

      -- optional: slightly dim comment delimiters for less visual noise
      vim.api.nvim_set_hl(0, "RainbowDelimiterComment", { fg = "#665C54" })
    end,
  },
}
