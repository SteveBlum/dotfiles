return {
  {
    "tpope/vim-fugitive"
  },
  {
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
			})
			vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
			vim.keymap.set("n", "<leader>gb", ":Gitsigns blame<CR>", {})
		end,
	},
  {
    "harrisoncramer/gitlab.nvim",
    branch = "main",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "dlyongemallo/diffview-plus.nvim", -- Maintained fork of "sindrets/diffview.nvim".
      "stevearc/dressing.nvim", -- Recommended but not required. Better UI for pickers.
      "nvim-tree/nvim-web-devicons", -- Recommended but not required. Icons in discussion tree.
    },
    ---@type GitlabSettings
    opts = {}, -- Your configuration
  }
}
