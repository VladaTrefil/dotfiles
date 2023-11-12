local util = require('lspconfig.util')

return {
	cmd = {
		'bundle exec rubocop',
		'--config "$XDG_CONFIG_HOME/rubocop/rubocop.yml"',
		'--require rubocop-rails',
		'--require rubocop-performance',
	},
	root_dir = util.root_pattern('Gemfile', '.git'),
}
