" Theme:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Init Theme: {{{
hi clear
if exists("syntax_on")
  syntax reset
endif

" Enable true color
set termguicolors

" Double sign column
set signcolumn=yes:2
set background=dark

set background=dark

" Enable popup transparency
set pumblend=15

let s:vim_bg  = 'bg'
let s:vim_fg  = 'fg'
let s:none    = 'NONE'

let s:bold = 'bold,'
let s:italic = 'italic,'
let s:underline = 'underline,'
let s:undercurl = 'undercurl,'
let s:inverse = 'inverse,'

let s:invert_signs = ''
let s:invert_tabline = ''
let s:invert_selection = s:inverse

" }}}

" Highlighting Function: {{{

" Build local palette
for [key, value] in items(g:palette)
  exe "let s:" . key . " = '" . value . "'"
endfor

function! s:HL(group, fg, ...)
  " Arguments: group, guifg, guibg, gui, guisp

  " foreground
  let fg = a:fg

  " background
  if a:0 >= 1
    let bg = a:1
  else
    let bg = s:none
  endif

  " emphasis
  if a:0 >= 2 && strlen(a:2)
    let emstr = a:2
  else
    let emstr = 'NONE,'
  endif

  let histring = [ 'hi', a:group, 'guifg=' . fg, 'guibg=' . bg, 'gui=' . emstr[:-2] ]

  " special
  if a:0 >= 3
    call add(histring, 'guisp=' . a:3[0])
  endif

  execute join(histring, ' ')
endfunction

" }}}

" Hi Groups: {{{

" memoize common hi groups
call s:HL('Fg0',  s:fg0)
call s:HL('Fg1',  s:fg1)
call s:HL('Fg2',  s:fg2)
call s:HL('Fg3',  s:fg3)
call s:HL('Fg4',  s:fg4)
call s:HL('Gray', s:gray)
call s:HL('Bg0',  s:bg0)
call s:HL('Bg1',  s:bg1)
call s:HL('Bg2',  s:bg2)
call s:HL('Bg3',  s:bg3)
call s:HL('Bg4',  s:bg4)

call s:HL('Red',        s:bright_red)
call s:HL('RedBold',    s:bright_red, s:none, s:bold)
call s:HL('Green',      s:bright_green)
call s:HL('GreenBold',  s:bright_green, s:none, s:bold)
call s:HL('Yellow',     s:bright_yellow)
call s:HL('YellowBold', s:bright_yellow, s:none, s:bold)
call s:HL('Blue',       s:bright_blue)
call s:HL('BlueBold',   s:bright_blue, s:none, s:bold)
call s:HL('Purple',     s:purple)
call s:HL('PurpleBold', s:bright_purple, s:none, s:bold)
call s:HL('Aqua',       s:bright_aqua)
call s:HL('AquaBold',   s:bright_aqua, s:none, s:bold)
call s:HL('Orange',     s:bright_orange)
call s:HL('OrangeBold', s:bright_orange, s:none, s:bold)

call s:HL('RedSign',    s:bright_red, s:bg0, s:invert_signs)
call s:HL('GreenSign',  s:bright_green, s:bg0, s:invert_signs)
call s:HL('YellowSign', s:bright_yellow, s:bg0, s:invert_signs)
call s:HL('BlueSign',   s:bright_blue, s:bg0, s:invert_signs)
call s:HL('PurpleSign', s:bright_purple, s:bg0, s:invert_signs)
call s:HL('AquaSign',   s:bright_aqua, s:bg0, s:invert_signs)
call s:HL('OrangeSign', s:bright_orange, s:bg0, s:invert_signs)

" }}}

" Vanilla Vim -------------------------------------------------------------
" General UI: {{{

" Normal text
call s:HL('Normal', s:fg0, s:bg0)

" Screen line that the cursor is
call s:HL('CursorLine', s:none, s:bg2)
" Screen column that the cursor is
hi! link CursorColumn CursorLine

" Tab pages line filler
call s:HL('TabLineFill', s:fg0, s:bg0, s:invert_tabline)
" Active tab page label
call s:HL('TabLineSel', s:bright_aqua, s:bg0, s:invert_tabline)
" Not active tab page label
hi! link TabLine TabLineFill

" Match paired bracket under the cursor
call s:HL('MatchParen', s:none, s:bg3, s:bold)

" Highlighted screen columns

" Concealed element: \lambda → λ
call s:HL('Conceal', s:bright_blue, s:none)

" Line number of CursorLine
call s:HL('CursorLineNr', s:bright_orange, s:bg0)

hi! link NonText Bg2
hi! link SpecialKey Bg2

call s:HL('Visual', s:none,  s:bg3, s:invert_selection)
hi! link VisualNOS Visual

call s:HL('Search', s:yellow, s:bg0, s:inverse)
call s:HL('IncSearch', s:yellow, s:bg0, s:inverse)

call s:HL('Underlined', s:bright_blue, s:none, s:underline)

" call s:HL('StatusLine', s:bg2, s:bright_orange, s:inverse)
" call s:HL('StatusLineNC', s:bg2, s:fg0, s:inverse)

" The column separating vertically split windows
call s:HL('VertSplit', s:bg2, s:bg0)

" Current match in wildmenu completion
call s:HL('WildMenu', s:bright_blue, s:bg2, s:bold)

" Directory names, special names in listing
hi! link Directory GreenBold

" Titles for output from :set all, :autocmd, etc.
hi! link Title GreenBold

" Error messages on the command line
call s:HL('ErrorMsg', s:bg0, s:bright_red, s:bold)
" More prompt: -- More --
hi! link MoreMsg YellowBold
" Current mode message: -- INSERT --
hi! link ModeMsg YellowBold
" 'Press enter' prompt and yes/no questions
hi! link Question OrangeBold
" Warning messages
hi! link WarningMsg RedBold

call s:HL('EndOfBuffer', s:vim_bg)

" }}}
" Gutter: {{{

" Line number for :number and :# commands
call s:HL('LineNr', s:gray, s:bg0)

" Column where signs are displayed
call s:HL('SignColumn', s:fg2, s:bg0)

" Line used for closed folds
call s:HL('Folded', s:faded_blue, s:bg1, s:italic)
" Column where folds are displayed
call s:HL('FoldColumn', s:gray, s:bg1)

" }}}
" Cursor: {{{

" Character under cursor
call s:HL('Cursor', s:none, s:none, s:inverse)
" Visual mode cursor, selection
hi! link vCursor Cursor
" Input moder cursor
hi! link iCursor Cursor
" Language mapping cursor
hi! link lCursor Cursor

" }}}
" Syntax Highlighting: {{{

call s:HL('Special', s:bright_orange, s:bg1, s:italic)
call s:HL('Comment', s:gray, s:none, s:italic)
call s:HL('Todo', s:vim_fg, s:vim_bg, s:bold . s:italic)
call s:HL('Error', s:bright_red, s:vim_bg, s:bold . s:inverse)

" Generic statement
hi! link Statement Red
" if, then, else, endif, swicth, etc.
hi! link Conditional Red
" for, do, while, etc.
hi! link Repeat Red
" case, default, etc.
hi! link Label Red
" try, catch, throw
hi! link Exception Red
" sizeof, "+", "*", etc.
hi! link Operator Normal
" Any other keyword
hi! link Keyword Red

" Variable name
hi! link Identifier Blue
" Function name
hi! link Function GreenBold

" Generic preprocessor
hi! link PreProc Aqua
" Preprocessor #include
hi! link Include Aqua
" Preprocessor #define
hi! link Define Aqua
" Same as Define
hi! link Macro Aqua
" Preprocessor #if, #else, #endif, etc.
hi! link PreCondit Aqua

" Generic constant
hi! link Constant Purple
" Character constant: 'c', '/n'
hi! link Character Purple
" String constant: "this is a string"
call s:HL('String', s:bright_green, s:none, s:italic)
" Boolean constant: TRUE, false
hi! link Boolean Purple
" Number constant: 234, 0xff
hi! link Number Purple
" Floating point constant: 2.3e10
hi! link Float Purple

" Generic type
hi! link Type Yellow
" static, register, volatile, etc
hi! link StorageClass Orange
" struct, union, enum, etc.
hi! link Structure Aqua
" typedef
hi! link Typedef Yellow

" }}}
" Completion Menu: {{{

" Popup menu: normal item
call s:HL('Pmenu', s:fg1, s:bg2)
" Popup menu: selected item
call s:HL('PmenuSel', s:bg2, s:bright_blue, s:bold)
" Popup menu: scrollbar
call s:HL('PmenuSbar', s:none, s:bg2)
" Popup menu: scrollbar thumb
call s:HL('PmenuThumb', s:none, s:bg4)

" }}}
" Diffs: {{{

call s:HL('DiffDelete', s:bright_red, s:bg0, s:inverse)
call s:HL('DiffAdd',    s:bright_green, s:bg0, s:inverse)
call s:HL('DiffChange', s:bright_aqua, s:bg0, s:inverse)
call s:HL('DiffText',   s:bright_yellow, s:bg0, s:inverse)

" }}}
" Spelling: {{{

if has("spell")
  " Not capitalised word, or compile warnings
  call s:HL('SpellCap',   s:bright_green, s:none, s:bold . s:italic)
  " Not recognized word
  call s:HL('SpellBad',   s:none, s:none, s:undercurl, s:bright_blue)
  " Wrong spelling for selected region
  call s:HL('SpellLocal', s:none, s:none, s:undercurl, s:bright_aqua)
  " Rare word
  call s:HL('SpellRare',  s:none, s:none, s:undercurl, s:bright_purple)
endif

" }}}

" Plugin specific -------------------------------------------------------------
" IndentLine: {{{

if !exists('g:indentLine_color_gui')
  let g:indentLine_color_gui = s:bg4
endif

" }}}
" GitGutter: {{{

hi! link GitGutterAdd GreenSign
hi! link GitGutterChange AquaSign
hi! link GitGutterDelete RedSign
hi! link GitGutterChangeDelete AquaSign

" }}}
" Asynchronous Lint Engine: {{{

call s:HL('ALEError', s:none, s:none, s:undercurl, s:bright_red)
call s:HL('ALEWarning', s:none, s:none, s:undercurl, s:bright_yellow)
call s:HL('ALEInfo', s:none, s:none, s:undercurl, s:bright_blue)

hi! link ALEErrorSign RedSign
hi! link ALEWarningSign YellowSign
hi! link ALEInfoSign BlueSign

" }}}
" CMP: {{{

" The menu field's highlight group.
call s:HL('CmpPmenu', s:fg0, s:none)
call s:HL('CmpPmenuBorder', s:bright_blue, s:none)
call s:HL('PmenuSel', s:fg0, s:bg4)

highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
" blue
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
" light blue
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
" pink
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
" front
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4

" }}}
" EasyMotion: {{{

call s:HL('EasyMotionTarget', s:yellow, s:none, s:bold)
call s:HL('EasyMotionTarget2First', s:faded_yellow, s:none, s:bold)
call s:HL('EasyMotionTarget2Second', s:yellow, s:none, s:bold)
call s:HL('EasyMotionShade', s:bg4, s:none, s:italic)

" }}}
" Lualine: {{{

  call s:HL('lualine_a_normal',   s:bg0,  s:aqua, s:bold)
  call s:HL('lualine_b_normal',   s:fg0,  s:bg2, s:bold)
  call s:HL('lualine_c_normal',   s:bg0,  s:bg0, s:bold)
  call s:HL('lualine_a_insert',   s:bg0,  s:yellow, s:bold)
  call s:HL('lualine_a_replace',  s:bg0,  s:orange, s:bold)
  call s:HL('lualine_a_visual',   s:fg0,  s:bright_red, s:bold)
  call s:HL('lualine_a_inactive', s:bg2,  s:bg1)
  call s:HL('lualine_b_inactive', s:none, s:bg1)
  call s:HL('lualine_c_inactive', s:none, s:bg1)

" }}}

" Filetype specific -----------------------------------------------------------
" Diff: {{{

hi! link diffAdded Green
hi! link diffRemoved Red
hi! link diffChanged Aqua

hi! link diffFile Orange
hi! link diffNewFile Yellow

hi! link diffLine Blue

" }}}
" Html: {{{

hi! link htmlTag Blue
hi! link htmlEndTag Blue

hi! link htmlTagName AquaBold
hi! link htmlArg Aqua

hi! link htmlScriptTag Purple
hi! link htmlTagN Fg1
hi! link htmlSpecialTagName AquaBold

call s:HL('htmlLink', s:fg4, s:none, s:underline)

hi! link htmlSpecialChar Orange

call s:HL('htmlBold', s:vim_fg, s:vim_bg, s:bold)
call s:HL('htmlBoldUnderline', s:vim_fg, s:vim_bg, s:bold . s:underline)
call s:HL('htmlBoldItalic', s:vim_fg, s:vim_bg, s:bold . s:italic)
call s:HL('htmlBoldUnderlineItalic', s:vim_fg, s:vim_bg, s:bold . s:underline . s:italic)

call s:HL('htmlUnderline', s:vim_fg, s:vim_bg, s:underline)
call s:HL('htmlUnderlineItalic', s:vim_fg, s:vim_bg, s:underline . s:italic)
call s:HL('htmlItalic', s:vim_fg, s:vim_bg, s:italic)

" }}}
" Xml: {{{

hi! link xmlTag Blue
hi! link xmlEndTag Blue
hi! link xmlTagName Blue
hi! link xmlEqual Blue
hi! link docbkKeyword AquaBold

hi! link xmlDocTypeDecl Gray
hi! link xmlDocTypeKeyword Purple
hi! link xmlCdataStart Gray
hi! link xmlCdataCdata Purple
hi! link dtdFunction Gray
hi! link dtdTagName Purple

hi! link xmlAttrib Aqua
hi! link xmlProcessingDelim Gray
hi! link dtdParamEntityPunct Gray
hi! link dtdParamEntityDPunct Gray
hi! link xmlAttribPunct Gray

hi! link xmlEntity Orange
hi! link xmlEntityPunct Orange
" }}}
" Vim: {{{

call s:HL('vimCommentTitle', s:fg4, s:none, s:bold . s:italic)

hi! link vimNotation Orange
hi! link vimBracket Orange
hi! link vimMapModKey Orange
hi! link vimFuncSID Fg3
hi! link vimSetSep Fg3
hi! link vimSep Fg3
hi! link vimContinue Fg3

" }}}
" CSS: {{{

hi! link cssBraces Blue
hi! link cssFunctionName Yellow
hi! link cssIdentifier Orange
hi! link cssClassName Green
hi! link cssColor Blue
hi! link cssSelectorOp Blue
hi! link cssSelectorOp2 Blue
hi! link cssImportant Green
hi! link cssVendor Fg0

hi! link cssTextProp Aqua
hi! link cssAnimationProp Aqua
hi! link cssUIProp Yellow
hi! link cssTransformProp Aqua
hi! link cssTransitionProp Aqua
hi! link cssPrintProp Aqua
hi! link cssPositioningProp Yellow
hi! link cssBoxProp Aqua
hi! link cssFontDescriptorProp Aqua
hi! link cssFlexibleBoxProp Aqua
hi! link cssBorderOutlineProp Aqua
hi! link cssBackgroundProp Aqua
hi! link cssMarginProp Aqua
hi! link cssListProp Aqua
hi! link cssTableProp Aqua
hi! link cssFontProp Aqua
hi! link cssPaddingProp Aqua
hi! link cssDimensionProp Aqua
hi! link cssRenderProp Aqua
hi! link cssColorProp Aqua
hi! link cssGeneratedContentProp Aqua

" }}}
" JavaScript: {{{

hi! link javaScriptBraces Fg1
hi! link javaScriptFunction Aqua
hi! link javaScriptIdentifier Red
hi! link javaScriptMember Blue
hi! link javaScriptNumber Purple
hi! link javaScriptNull Purple
hi! link javaScriptParens Fg3

" }}}
" YAJS: {{{

hi! link javascriptImport Aqua
hi! link javascriptExport Aqua
hi! link javascriptClassKeyword Aqua
hi! link javascriptClassExtends Aqua
hi! link javascriptDefault Aqua

hi! link javascriptClassName Yellow
hi! link javascriptClassSuperName Yellow
hi! link javascriptGlobal Yellow

hi! link javascriptEndColons Fg1
hi! link javascriptFuncArg Fg1
hi! link javascriptGlobalMethod Fg1
hi! link javascriptNodeGlobal Fg1
hi! link javascriptBOMWindowProp Fg1
hi! link javascriptArrayMethod Fg1
hi! link javascriptArrayStaticMethod Fg1
hi! link javascriptCacheMethod Fg1
hi! link javascriptDateMethod Fg1
hi! link javascriptMathStaticMethod Fg1

" hi! link javascriptProp Fg1
hi! link javascriptURLUtilsProp Fg1
hi! link javascriptBOMNavigatorProp Fg1
hi! link javascriptDOMDocMethod Fg1
hi! link javascriptDOMDocProp Fg1
hi! link javascriptBOMLocationMethod Fg1
hi! link javascriptBOMWindowMethod Fg1
hi! link javascriptStringMethod Fg1

hi! link javascriptVariable Orange
" hi! link javascriptVariable Red
" hi! link javascriptIdentifier Orange
" hi! link javascriptClassSuper Orange
hi! link javascriptIdentifier Orange
hi! link javascriptClassSuper Orange

" hi! link javascriptFuncKeyword Orange
" hi! link javascriptAsyncFunc Orange
hi! link javascriptFuncKeyword Aqua
hi! link javascriptAsyncFunc Aqua
hi! link javascriptClassStatic Orange

hi! link javascriptOperator Red
hi! link javascriptForOperator Red
hi! link javascriptYield Red
hi! link javascriptExceptions Red
hi! link javascriptMessage Red

hi! link javascriptTemplateSB Aqua
hi! link javascriptTemplateSubstitution Fg1

" hi! link javascriptLabel Blue
" hi! link javascriptObjectLabel Blue
" hi! link javascriptPropertyName Blue
hi! link javascriptLabel Fg1
hi! link javascriptObjectLabel Fg1
hi! link javascriptPropertyName Fg1

hi! link javascriptLogicSymbols Fg1
hi! link javascriptArrowFunc Yellow

hi! link javascriptDocParamName Fg4
hi! link javascriptDocTags Fg4
hi! link javascriptDocNotation Fg4
hi! link javascriptDocParamType Fg4
hi! link javascriptDocNamedParamType Fg4

hi! link javascriptBrackets Fg1
hi! link javascriptDOMElemAttrs Fg1
hi! link javascriptDOMEventMethod Fg1
hi! link javascriptDOMNodeMethod Fg1
hi! link javascriptDOMStorageMethod Fg1
hi! link javascriptHeadersMethod Fg1

hi! link javascriptAsyncFuncKeyword Red
hi! link javascriptAwaitFuncKeyword Red

" }}}
" TypeScript: {{{

hi! link typeScriptReserved Aqua
hi! link typeScriptLabel Aqua
hi! link typeScriptFuncKeyword Aqua
hi! link typeScriptIdentifier Orange
hi! link typeScriptBraces Fg1
hi! link typeScriptEndColons Fg1
hi! link typeScriptDOMObjects Fg1
hi! link typeScriptAjaxMethods Fg1
hi! link typeScriptLogicSymbols Fg1
hi! link typeScriptDocSeeTag Comment
hi! link typeScriptDocParam Comment
hi! link typeScriptDocTags vimCommentTitle
hi! link typeScriptGlobalObjects Fg1
hi! link typeScriptParens Fg3
hi! link typeScriptOpSymbols Fg3
hi! link typeScriptHtmlElemProperties Fg1
hi! link typeScriptNull Purple
hi! link typeScriptInterpolationDelimiter Aqua

" }}}
" CoffeeScript: {{{

hi! link coffeeExtendedOp Fg3
hi! link coffeeSpecialOp Fg3
hi! link coffeeCurly Orange
hi! link coffeeParen Fg3
hi! link coffeeBracket Orange

" }}}
" Ruby: {{{

hi! link rubyStringDelimiter Green
hi! link rubyInterpolationDelimiter Aqua

" }}}
" Lua: {{{

hi! link luaIn Red
hi! link luaFunction Aqua
hi! link luaTable Orange

" }}}
" Java: {{{

hi! link javaAnnotation Blue
hi! link javaDocTags Aqua
hi! link javaCommentTitle vimCommentTitle
hi! link javaParen Fg3
hi! link javaParen1 Fg3
hi! link javaParen2 Fg3
hi! link javaParen3 Fg3
hi! link javaParen4 Fg3
hi! link javaParen5 Fg3
hi! link javaOperator Orange

hi! link javaVarArg Green

" }}}
" Markdown: {{{

call s:HL('markdownItalic', s:fg3, s:none, s:italic)

hi! link markdownH1 GreenBold
hi! link markdownH2 GreenBold
hi! link markdownH3 YellowBold
hi! link markdownH4 YellowBold
hi! link markdownH5 Yellow
hi! link markdownH6 Yellow

hi! link markdownCode Aqua
hi! link markdownCodeBlock Aqua
hi! link markdownCodeDelimiter Aqua

hi! link markdownBlockquote Gray
hi! link markdownListMarker Gray
hi! link markdownOrderedListMarker Gray
hi! link markdownRule Gray
hi! link markdownHeadingRule Gray

hi! link markdownUrlDelimiter Fg3
hi! link markdownLinkDelimiter Fg3
hi! link markdownLinkTextDelimiter Fg3

hi! link markdownHeadingDelimiter Orange
hi! link markdownUrl Purple
hi! link markdownUrlTitleDelimiter Green

call s:HL('markdownLinkText', s:gray, s:none, s:underline)
hi! link markdownIdDeclaration markdownLinkText

" }}}
" Json: {{{

hi! link jsonKeyword Green
hi! link jsonQuote Green
hi! link jsonBraces Fg1
hi! link jsonString Fg1

" }}}
