local colors = require('theme.colors')

local config = {
	xmlTag = { link = 'Blue' },
	xmlEndTag = { link = 'Blue' },
	xmlTagName = { link = 'Blue' },
	xmlEqual = { link = 'Blue' },
	docbkKeyword = { link = 'AquaBold' },

	xmlDocTypeDecl = { link = 'Gray' },
	xmlDocTypeKeyword = { link = 'Purple' },
	xmlCdataStart = { link = 'Gray' },
	xmlCdataCdata = { link = 'Purple' },
	dtdFunction = { link = 'Gray' },
	dtdTagName = { link = 'Purple' },

	xmlAttrib = { link = 'Aqua' },
	xmlProcessingDelim = { link = 'Gray' },
	dtdParamEntityPunct = { link = 'Gray' },
	dtdParamEntityDPunct = { link = 'Gray' },
	xmlAttribPunct = { link = 'Gray' },

	xmlEntity = { link = 'Orange' },
	xmlEntityPunct = { link = 'Orange' },
}

return config
