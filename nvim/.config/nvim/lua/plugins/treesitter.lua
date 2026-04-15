return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
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
      "helm"
		}

		for _, parser in ipairs(parsers) do
			ts.install(parser)
		end

		vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo[0][0].foldmethod = "expr"
		vim.api.nvim_command("set nofoldenable")

    -- helm chart template handling
    vim.filetype.add({
      extension = {
        yaml = function(path, bufnr)
          if vim.fn.search("{{", "nw") ~= 0 then
            return "helm"
          end
          return "yaml"
        end,
      },
      pattern = {
        [".*/templates/.*%.yaml"] = "helm",
        [".*/templates/.*%.tpl"] = "helm",
        ["helmfile.*%.yaml"] = "helm",
      },
    })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = parsers,
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
