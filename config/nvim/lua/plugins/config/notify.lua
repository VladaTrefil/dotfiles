local notify_ok, notify = pcall(require, 'notify')

if not notify_ok then
  vim.notify("Notify lua package doesn't exist ")
  return
end

notify.setup({
  max_width = 60,
  min_width = 0,
  timeout = 3000,
})

vim.notify = notify

require('plugins.config._telescope.utils').load_extension('notify')
