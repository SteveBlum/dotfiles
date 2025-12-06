return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"github/copilot.vim",
	},
	config = function()
		require("codecompanion").setup({
			adapters = {
				http = {
					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "gpt-5-mini",
								},
							},
						})
					end,
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							schema = {
								model = {
									default = "gemini-2.0-flash",
								},
							},
							env = {
								api_key = function()
									return os.getenv("GEMINI_API_KEY")
								end,
							},
						})
					end,
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							schema = {
								model = {
									default = "claude-3-7-sonnet-latest",
								},
							},
							env = {
								api_key = function()
									return os.getenv("CLAUDE_API_KEY")
								end,
							},
						})
					end,
				},
				acp = {
					gemini_cli = function()
						return require("codecompanion.adapters").extend("gemini_cli", {
							defaults = {
								auth_method = "gemini-api-key",
							},
							env = {
								GEMINI_API_KEY = function()
									return os.getenv("GEMINI_API_KEY")
								end,
							},
						})
					end,
				},
			},
			display = {
				chat = {
					start_in_insert_mode = true,
					window = {
						width = 0.2,
						position = "right",
					},
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
					tools = {
						["mcp"] = {
							-- calling it in a function would prevent mcphub from being loaded before it's needed
							callback = function()
								return require("mcphub.extensions.codecompanion")
							end,
							description = "Call tools and resources from the MCP Servers",
						},
					},
				},
				inline = {
					adapter = "gemini",
				},
			},
		})
		vim.keymap.set("n", "<C-a>", "<cmd>CodeCompanionActions<cr>")
		vim.keymap.set("n", "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>")
		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
