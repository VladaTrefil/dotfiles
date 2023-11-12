local neodev_ok, neodev = pcall(require, 'neodev')

if not neodev_ok then
  vim.notify("Neodev lua package doesn't exist ")
  return
end

neodev.setup()
