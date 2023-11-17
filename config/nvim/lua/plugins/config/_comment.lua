local comment_ok, comment = pcall(require, 'Comment')

if not comment_ok then
	vim.notify('Comment.nvim not installed', vim.log.levels.ERROR)
	return
end

comment.setup()
