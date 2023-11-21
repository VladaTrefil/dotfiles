local splitjoin_ok, splitjoin = pcall(require, 'mini.splitjoin')

if not splitjoin_ok then
  vim.notify('splitjoin not found', vim.log.levels.ERROR)
  return
end

splitjoin.setup({
  mappings = {
    toggle = '<leader>sj',
  },
})
