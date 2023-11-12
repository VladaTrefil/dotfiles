local trouble_ok, trouble = pcall(require, 'trouble')

if not trouble_ok then
  vim.notify("Trouble lua package doesn't exist ")
  return
end

trouble.setup()
