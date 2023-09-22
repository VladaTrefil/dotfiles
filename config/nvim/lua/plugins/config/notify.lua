local notify_ok, notify = pcall(require, 'notify')

if not notify_ok then
  return
end

notify.setup({
  max_width = 60,
  min_width = 0,
  timeout = 3000,
})

vim.notify = notify
