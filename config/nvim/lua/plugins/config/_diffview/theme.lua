local colors = require('theme.colors')

local config = {
	DiffviewDiffAdd = { link = 'DiffAdd' },
	DiffviewDiffChange = { link = 'DiffChange' },
	DiffviewDiffDelete = { link = 'DiffDelete' },
	DiffviewDiffText = { link = 'DiffText' },

	DiffViewNormal = { fg = colors.gray, bg = colors.dark0 },
	DiffviewStatusAdded = { fg = colors.green },
	DiffviewStatusModified = { fg = colors.blue },
	DiffviewStatusRenamed = { fg = colors.blue },
	DiffviewStatusDeleted = { fg = colors.red },
	DiffviewFilePanelInsertion = { fg = colors.green },
	DiffviewFilePanelDeletion = { fg = colors.red },
	DiffviewVertSplit = { bg = colors.dark0 },
}

return config
