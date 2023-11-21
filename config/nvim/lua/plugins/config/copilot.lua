local copilot_ok, copilot = pcall(require, 'copilot')

if not copilot_ok then
	return
end

-- add function for automatic copilot authentication

copilot.setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
  filetypes = {
    yaml = true,
    markdown = true,
  },
})
