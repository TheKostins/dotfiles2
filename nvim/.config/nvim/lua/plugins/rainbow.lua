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

      -- ── Catppuccin Mocha Palette ─────────────────────────────────────────────
      local colors = {
        red = "#F38BA8",
        yellow = "#F9E2AF",
        blue = "#89B4FA",
        orange = "#FAB387",
        green = "#A6E3A1",
        violet = "#CBA6F7",
        cyan = "#94E2D5",
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
      vim.api.nvim_set_hl(0, "RainbowDelimiterComment", { fg = "#585B70" })
    end,
  },
}
