local function server_argument()
	local output = vim.fn.system('bundle exec rubocop --server --version')

	if not output:match('--server') then
		return '--server'
	else
		return nil
	end
end

-- TODO: Add ignorelist for projects with incompatible rubocop config
-- local function config_path()
-- 	if vim.fn.filereadable(vim.fn.getcwd() .. '/.rubocop.yml') then
-- 		return vim.fn.getcwd() .. '/.rubocop.yml'
-- 	else
-- 		return vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml')
-- 	end
-- end

local function condition()
	return vim.fn.executable('bundle') > 0
end

-- print(table.concat({
-- 	'exec',
-- 	'rubocop',
-- 	'-a',
-- 	'-f',
-- 	'quiet',
-- 	'--force-exclusion',
-- 	'--config',
-- 	vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
-- 	server_argument(),
-- 	'--stderr',
-- 	'--stdin',
-- 	'$FILENAME',
-- }, ' '))

return {
	command = 'bundle',
	args = {
		'exec',
		'rubocop',
		'--autocorrect',
		'--format',
		'quiet',
		'--force-exclusion',
		'--config',
		vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
		-- config_path(),
		-- server_argument(),
		'--server',
		'--stderr',
		'--stdin',
		'$FILENAME',
	},
	condition = condition,
	exit_codes = { 0, 1 },
}
