local copilot_cmp_ok, copilot_cmp = pcall(require, 'copilot_cmp')

if not copilot_cmp_ok then
  return
end

copilot_cmp.setup()
