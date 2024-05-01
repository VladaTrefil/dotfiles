local root = require('conform.util').root_file({ '.git' })
local args = {}

-- Use global config if local config does not exist
if vim.fn.filereadable(vim.fn.getcwd() .. '/stylua.toml') == 0 then
	args = vim.list_extend(args, {
		'--config-path',
		vim.fn.expand('$XDG_CONFIG_HOME/stylua/stylua.toml'),
	})
end

return {
	prepend_args = args,
	cwd = root,
}
