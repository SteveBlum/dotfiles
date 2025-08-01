return {
	"jellydn/hurl.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	ft = "hurl",
	config = function()
		require("hurl").setup({
			debug = false,
			show_notification = false,
			mode = "split",
			formatters = {
				json = { "jq" },
				html = { "prettier", "--parser", "html" },
				xml = { "tidy", "-xml", "-i", "-q" },
			},
			mappings = {
				close = "q", -- Close the response popup or split view
				next_panel = "<C-n>", -- Move to the next response popup window
				prev_panel = "<C-p>", -- Move to the previous response popup window
			},
		})
	end,
	keys = {
		-- Run API request
		{ "<leader>A", "<cmd>HurlRunner<CR>", desc = "Run All requests" },
		-- Run Hurl request in visual mode
		{ "<leader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
	},
}
