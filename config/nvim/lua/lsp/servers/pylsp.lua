local util = require('lspconfig.util')

return {
	cmd = {
		'pylsp',
		'-v',
	},
	root_dir = util.root_pattern('.git', '__init__.py'),
}
