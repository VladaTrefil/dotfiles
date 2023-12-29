local mason_ok, mason = pcall(require, 'mason')
local icons = require('core.icons')

if not mason_ok then
	vim.notify("Mason lua package doesn't exist ")
	return
end

local ensure_installed = {
	'clang-format',
	'clangd',
	'codespell',
	'css-lsp',
	'eslint-lsp',
	'jsonlint',
	'lua-language-server',
	'prettier',
	'rubocop',
	'rustfmt',
	'selene',
	'shellcheck',
	'stylua',
	'typescript-language-server',
	'vim-language-server',
	'yaml-language-server',
}

mason.setup({
	max_concurrent_installers = 10,
	ui = {
		icons = {
			package_installed = icons.Success,
			package_uninstalled = icons.Failure,
			package_pending = icons.Pending,
		},
	},
})

local registry = require('mason-registry')
local installed = registry.get_installed_package_names()
local to_install = {}

-- Filter out packages that are already installed
for _, package in ipairs(ensure_installed) do
	if not vim.tbl_contains(installed, package) then
		table.insert(to_install, package)
	end
end

if #to_install > 0 then
	vim.cmd('MasonInstall --force ' .. table.concat(to_install, ' '))
end
