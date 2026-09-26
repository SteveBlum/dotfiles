return {
	"nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.completion.spell,
			  require("none-ls.diagnostics.eslint_d").with({
          condition = function(utils)
            return utils.root_has_file_matches("^%.eslintrc")
                or utils.root_has_file_matches("^eslint%.config")
          end,
        }),
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort
      },
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
