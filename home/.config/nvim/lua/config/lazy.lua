-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"mason-org/mason-lspconfig.nvim",
			opts = {},
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"neovim/nvim-lspconfig",
			},
		},
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPost", "BufNewFile" },
			cmd = { "LspInfo", "LspInstall", "LspUinstall", "LspStart", "LspStop", "LspRestart" },
			config = function()
				local lspconfig = require("lspconfig")

				lspconfig.clangd.setup({})
				lspconfig.rust_analyzer.setup({})
				lspconfig.sourcekit.setup({
					capabilities = {
						workspace = {
							didChangeWatchedFiles = {
								dynamicRegistration = true,
							},
						},
					},
				})

				vim.api.nvim_create_autocmd("LspAttach", {
					desc = "LSP Actions",
					callback = function(args)
						-- Once we've attached, configure the keybindings
						local wk = require("which-key")
						wk.register({
							K = { vim.lsp.buf.hover, "LSP hover info" },
							gd = { vim.lsp.buf.definition, "LSP go to definition" },
							gD = { vim.lsp.buf.declaration, "LSP go to declaration" },
							gi = { vim.lsp.buf.implementation, "LSP go to implementation" },
							gr = { vim.lsp.buf.references, "LSP list references" },
							gs = { vim.lsp.buf.signature_help, "LSP signature help" },
							gn = { vim.lsp.buf.rename, "LSP rename" },
							["[g"] = { vim.diagnostic.goto_prev, "Go to previous diagnostic" },
							["g]"] = { vim.diagnostic.goto_next, "Go to next diagnostic" },
						}, {
							mode = "n",
							silent = true,
						})
					end,
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>P",
					function()
						require("conform").format({ async = true })
					end,
					mode = "",
					desc = "Format buffer",
				},
			},
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					rust = { "rustfmt" },
					swift = { "swiftformat" },
				},
				default_format_opts = {
					lsp_format = "fallback",
				},
			},
		},
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer", -- source for text in buffer
				"hrsh7th/cmp-path", -- source for file system paths
				"L3MON4D3/LuaSnip", -- snippet engine
				"saadparwaiz1/cmp_luasnip", -- for autocompletion
				"rafamadriz/friendly-snippets", -- useful snippets
				"onsails/lspkind.nvim", -- vs-code like pictograms
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")
				local lspkind = require("lspkind")

				-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
				require("luasnip.loaders.from_vscode").lazy_load()
				cmp.setup({
					completion = {
						completeopt = "menu,menuone,preview",
					},
					snippet = { -- configure how nvim-cmp interacts with snippet engine
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
						["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
						["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
						["<C-e>"] = cmp.mapping.abort(), -- close completion window
						["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
						["<C-b>"] = cmp.mapping(function(fallback)
							if luasnip.jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end, { "i", "s" }),
						["<C-f>"] = cmp.mapping(function(fallback)
							if luasnip.jumpable(1) then
								luasnip.jump(1)
							else
								fallback()
							end
						end, { "i", "s" }),
					}),
					-- sources for autocompletion
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" }, -- snippets
						{ name = "buffer" }, -- text within current buffer
						{ name = "path" }, -- file system paths
					}),
					-- configure lspkind for vs-code like pictograms in completion menu
					formatting = {
						format = lspkind.cmp_format({
							maxwidth = 50,
							ellipsis_char = "...",
						}),
					},
				})
			end,
		},
		"zapling/mason-conform.nvim",
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {},
			keys = {
				{
					"<leader>?",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
		{
			"RaafatTurki/hex.nvim",
			config = function()
				require("hex").setup({})
			end,
		},
		{
			"mfussenegger/nvim-dap",
		},
		{
			"MunifTanjim/nui.nvim",
		},
		{
			"folke/snacks.nvim",
			priority = 1000,
			lazy = false,
			---@type snacks.Config
			opts = {},
		},
		-- Detect tabstop and shiftwidth automatically
		"tpope/vim-sleuth",
		{ "j-hui/fidget.nvim", opt = {} },
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{
			"folke/tokyonight.nvim",
			lazy = false,
			priority = 1000,
			opts = {},
		},
		{
			"nvim-tree/nvim-tree.lua",
			version = "*",
			lazy = false,
			config = function()
				require("nvim-tree").setup({})
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
		},
		{
			"nvim-neotest/neotest",
			dependencies = {
				"nvim-neotest/nvim-nio",
				"nvim-lua/plenary.nvim",
				"antoinemadec/FixCursorHold.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
		},
		{
			"wojciech-kulik/xcodebuild.nvim",
			dependencies = {
				"nvim-telescope/telescope.nvim",
				"MunifTanjim/nui.nvim",
				"folke/snacks.nvim", -- (optional) to show previews
				"nvim-tree/nvim-tree.lua", -- (optional) to manage project files
				"nvim-treesitter/nvim-treesitter", -- (optional) for Quick tests support (required Swift parser)
			},
			config = function()
				require("xcodebuild").setup({
					-- put some options here or leave it empty to use default settings
				})
			end,
		},
		{
			"mrcjkb/rustaceanvim",
			version = "^5",
			lazy = false,
		},
		{
			"folke/trouble.nvim",
			opts = {},
			cmd = "Trouble",
			keys = {
				{
					"<leader>dt",
					"<cmd>Trouble diagnostics toggle<cr>",
					desc = "Diagnostics (Trouble)",
				},
			},
		},
		{
			"folke/flash.nvim",
			event = "VeryLazy",
			---@type Flash.Config
			opts = {},
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})
