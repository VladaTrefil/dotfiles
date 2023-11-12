local mason_ok, mason = pcall(require, 'mason')
local icons = require('core.icons')

if not mason_ok then
  vim.notify("Mason lua package doesn't exist ")
  return
end

mason.setup({
  ui = {
    icons = {
      package_installed = icons.Success,
      package_uninstalled = icons.Failure,
      package_pending = icons.Pending,
    },
  },
})
