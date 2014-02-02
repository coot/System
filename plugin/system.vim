" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see :help license
"
" This is a tiny vim script which might have been discvered ages ago (but I am
" unaware). Its rather for vim than gvim users.
"
" When executing commands from vim you enter a vim shell where you see the
" output. In many situations this is not what you want and you'd prefere 
" :call system("command")
" but it is a lot to type, and you don't have completion. With this snipet
" every command which starts with:
" :! command
" (note the space after the "!") will be wrapped into system() and the output will be
" echoed. The plugin refreshes the histry with what you typed rather than the
" call to the system() function.
"
" There is some configuration variables:
" g:system_expand = 1
"         by default % (with modifiers) is expanded in the same way as by the :!.
" g:system_echocmd = 0
"         echo the command together with its output (by default off)
"
" The reason why I like it is that I have different background colors in vim
" (dark) and terminal (light). If I stay inside vim I am not flushed with
" bright colors which is a anoying (and eyes tireing).
"
" Benefits: you get completion for system commanads and system files.
" Drawbacks: if you want to write a function. You can source the plugin
" afterwards to restore the cmap (or write a simple toggle map if you do that
" often). You can use the expression register with Vim 7.3.686.
" Copyright: © Marcin Szamotulski, 2012-2014

" I learned how to do that reading the emacscommandline plugin.
"
" Other plugins with shell like functionality:
" vim-addon-async by Marc Weber: https://github.com/MarcWeber/vim-addon-async
" Conque Shell plugin: http://code.google.com/p/conque
" vimproc plugin: http://github.com/Shougo/vimproc/tree/master/doc/vimproc.txt
"
" Happy viming,
"  Marcin Szamotulski

if !exists("g:system_expand")
    let g:system_expand = 1
    " If 1 expand % as in the command line.
endif
if !exists("g:system_echocmd")
    let g:system_echocmd = 0
endif

if !exists('CRDispatcher')
    let g:CRDispatcher = {}
    fun g:CRDispatcher.dispatch() dict
	let cmdtype = getcmdtype()
	if cmdtype == ':'
	   if has_key(self, 'expr')
	       return self.expr()
	   endif
	elseif cmdtype == '/'
	    if has_key(self, 'search')
		return self.search()
	    endif
	endif
	return getcmdline()
    endfun
endif
if !exists('*CRDispatch')
    fun CRDispatch()
	return g:CRDispatcher.dispatch()
    endfun
endif

fun! WrapCmdLine() " {{{
    let cmdline = getcmdline()
    " Add cmdline to the history
    if cmdline[0:1] == "! "  
	let cmd = cmdline[2:]
	call histadd(":", cmdline)
	if g:system_expand
	    let cmd_split = split(cmd, '\ze\\\@<!%')
	    let cmd = ""
	    for hunk in cmd_split
		if hunk[0] == '%'
		    let m = matchstr(hunk, '^%\%(:[p8~.htre]\|:g\=s?[^?]*?[^?]*?\)*')
		    let exp = expand(m)
		    let cmd .=exp.hunk[len(m):]
		else
		    let cmd .=hunk
		endif
	    endfor
	endif
	let cmd = escape(cmd, "\"")
	let his = "|call histdel(':', -1)"
	if g:system_echocmd
	    return "echo \"".cmd."\n\".system(\"".cmd."\")".his
	else
	    return "echo system(\"".cmd."\")".his
	endif
    endif
    return cmdline
endfun " }}}

if empty(maparg('<Plug>CRDispatch', 'c'))
    cno <Plug>CRDispatch <C-\>eCRDispatch()<CR><CR>
endif
" cno <Plug>eWrapCmdLine <C-\>eWrapCmdLine()<CR><CR>

if empty(globpath(&rtp, 'plugin/cmd_alias.vim'))
    " My cmd_alias.vim plugin will take care of this map.
    " This is important since both plugins define a cmap to <CR>.
    CRDispatcher.expr = funcref('WrapCmdLine')
endif
