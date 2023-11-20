local hardtime_ok, hardtime = pcall(require, 'hardtime')

if not hardtime_ok then
	return
end

hardtime.setup({
	max_time = 1500,
	max_count = 15,
	disable_mouse = false,
	restriction_mode = 'hint',
})
