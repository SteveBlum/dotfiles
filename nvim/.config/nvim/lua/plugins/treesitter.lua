return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		local parsers = {
			"lua",
			"javascript",
			"markdown",
			"rust",
			"yaml",
			"hurl",
		}

		for _, parser in ipairs(parsers) do
			ts.install(parser)
		end

		vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo[0][0].foldmethod = "expr"
		vim.api.nvim_command("set nofoldenable")

		vim.api.nvim_create_autocmd("FileType", {
			pattern = parsers,
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
