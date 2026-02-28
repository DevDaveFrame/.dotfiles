return {
	dir = vim.fn.expand("~/Develop/claudev"),
	name = "claudev",
	config = function()
		require("claudev").setup({})
	end,
}
