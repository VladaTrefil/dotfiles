local function config_path()
	if vim.fn.filereadable(vim.fn.getcwd() .. '/stylua.toml') == 0 then
		return {
			'--config-path',
			vim.fn.expand('$XDG_CONFIG_HOME/stylua/stylua.toml'),
		}
	end
end

return {
	prepend_args = {
		config_path(),
	},
	cwd = require('conform.util').root_file({ '.git' }),
}
