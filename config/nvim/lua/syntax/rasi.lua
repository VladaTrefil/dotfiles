return function()
	if vim.b.current_syntax then
		return
	end

	vim.b.current_syntax = 'rasi'
	vim.opt_local.filetype = 'rasi'

	vim.cmd([[
    syntax case match

    syntax region rasiString start="\"" skip="\." end="\""

    syntax match rasiComment "/\*.*\*/$"

    syntax match rasiStatement "^.*{$"
    syntax match rasiStatement "}"

    syntax match rasiNumber "\d\+"
    syntax match rasiNumber "\d\+px"
    syntax match rasiNumber "\d\+%"
    syntax match rasiNumber /\<\d\+\.\d*\%([eE][-+]\=\d\+\)\=/
    syntax match rasiNumber /\.\d\+\%([eE][-+]\=\d\+\)\=\>/
    syntax match rasiNumber /\<\d\+[eE][-+]\=\d\+\>/
    syntax match rasiNumber /\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>/
    syntax match rasiNumber "#\x*"

    syntax keyword rasiBoolean false true

    syntax match rasiIdentifier "@\w\+\(-\w\+\)*"
    syntax match rasiDefine "^@\w\+"
    syntax match rasiNormal "\w\+:"

    syntax sync fromstart
  ]])
end
