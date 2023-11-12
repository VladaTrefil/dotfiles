local M = {}

M.settings = {
	Lua = {
		diagnostics = {
			globals = { 'vim', 'packer_plugins' },
		},
    hint = {
      setType = true
    },
	},
}

return M
