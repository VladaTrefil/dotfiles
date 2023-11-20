local colors = require('theme.colors')

local config = {
	javaScriptBraces = { link = 'Fg1' },
	javaScriptFunction = { link = 'Aqua' },
	javaScriptIdentifier = { link = 'Red' },
	javaScriptMember = { link = 'Blue' },
	javaScriptNumber = { link = 'Purple' },
	javaScriptNull = { link = 'Purple' },
	javaScriptParens = { link = 'Fg3' },

	-- YAJS
	javascriptImport = { link = 'Aqua' },
	javascriptExport = { link = 'Aqua' },
	javascriptClassKeyword = { link = 'Aqua' },
	javascriptClassExtends = { link = 'Aqua' },
	javascriptDefault = { link = 'Aqua' },

	javascriptClassName = { link = 'Yellow' },
	javascriptClassSuperName = { link = 'Yellow' },
	javascriptGlobal = { link = 'Yellow' },

	javascriptEndColons = { link = 'Fg1' },
	javascriptFuncArg = { link = 'Fg1' },
	javascriptGlobalMethod = { link = 'Fg1' },
	javascriptNodeGlobal = { link = 'Fg1' },
	javascriptBOMWindowProp = { link = 'Fg1' },
	javascriptArrayMethod = { link = 'Fg1' },
	javascriptArrayStaticMethod = { link = 'Fg1' },
	javascriptCacheMethod = { link = 'Fg1' },
	javascriptDateMethod = { link = 'Fg1' },
	javascriptMathStaticMethod = { link = 'Fg1' },

	javascriptURLUtilsProp = { link = 'Fg1' },
	javascriptBOMNavigatorProp = { link = 'Fg1' },
	javascriptDOMDocMethod = { link = 'Fg1' },
	javascriptDOMDocProp = { link = 'Fg1' },
	javascriptBOMLocationMethod = { link = 'Fg1' },
	javascriptBOMWindowMethod = { link = 'Fg1' },
	javascriptStringMethod = { link = 'Fg1' },

	javascriptVariable = { link = 'Orange' },
	javascriptVariable = { link = 'Red' },
	javascriptIdentifier = { link = 'Orange' },
	javascriptClassSuper = { link = 'Orange' },
	javascriptIdentifier = { link = 'Orange' },
	javascriptClassSuper = { link = 'Orange' },

	javascriptFuncKeyword = { link = 'Orange' },
	javascriptAsyncFunc = { link = 'Orange' },
	javascriptFuncKeyword = { link = 'Aqua' },
	javascriptAsyncFunc = { link = 'Aqua' },
	javascriptClassStatic = { link = 'Orange' },

	javascriptOperator = { link = 'Red' },
	javascriptForOperator = { link = 'Red' },
	javascriptYield = { link = 'Red' },
	javascriptExceptions = { link = 'Red' },
	javascriptMessage = { link = 'Red' },

	javascriptTemplateSB = { link = 'Aqua' },
	javascriptTemplateSubstitution = { link = 'Fg1' },

	javascriptLabel = { link = 'Blue' },
	javascriptObjectLabel = { link = 'Blue' },
	javascriptPropertyName = { link = 'Blue' },
	javascriptLabel = { link = 'Fg1' },
	javascriptObjectLabel = { link = 'Fg1' },
	javascriptPropertyName = { link = 'Fg1' },

	javascriptLogicSymbols = { link = 'Fg1' },
	javascriptArrowFunc = { link = 'Aqua' },

	javascriptDocParamName = { link = 'Fg4' },
	javascriptDocTags = { link = 'Fg4' },
	javascriptDocNotation = { link = 'Fg4' },
	javascriptDocParamType = { link = 'Fg4' },
	javascriptDocNamedParamType = { link = 'Fg4' },

	javascriptBrackets = { link = 'Fg1' },
	javascriptDOMElemAttrs = { link = 'Fg1' },
	javascriptDOMEventMethod = { link = 'Fg1' },
	javascriptDOMNodeMethod = { link = 'Fg1' },
	javascriptDOMStorageMethod = { link = 'Fg1' },
	javascriptHeadersMethod = { link = 'Fg1' },

	javascriptAsyncFuncKeyword = { link = 'Red' },
	javascriptAwaitFuncKeyword = { link = 'Red' },

	-- TypeScript
	typeScriptReserved = { link = 'Aqua' },
	typeScriptLabel = { link = 'Aqua' },
	typeScriptFuncKeyword = { link = 'Aqua' },
	typeScriptIdentifier = { link = 'Orange' },
	typeScriptBraces = { link = 'Fg1' },
	typeScriptEndColons = { link = 'Fg1' },
	typeScriptDOMObjects = { link = 'Fg1' },
	typeScriptAjaxMethods = { link = 'Fg1' },
	typeScriptLogicSymbols = { link = 'Fg1' },
	typeScriptDocSeeTag = { link = 'Comment' },
	typeScriptDocParam = { link = 'Comment' },
	typeScriptDocTags = { link = 'vimCommentTitle' },
	typeScriptGlobalObjects = { link = 'Fg1' },
	typeScriptParens = { link = 'Fg3' },
	typeScriptOpSymbols = { link = 'Fg3' },
	typeScriptHtmlElemProperties = { link = 'Fg1' },
	typeScriptNull = { link = 'Purple' },
	typeScriptInterpolationDelimiter = { link = 'Aqua' },

	-- CoffeeScript
	coffeeExtendedOp = { link = 'Fg3' },
	coffeeSpecialOp = { link = 'Fg3' },
	coffeeCurly = { link = 'Orange' },
	coffeeParen = { link = 'Fg3' },
	coffeeBracket = { link = 'Orange' },
}

return config
