" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see :help license
"

if !exists("g:system_expand")
    let g:system_expand = 1
    " If 1 expand % as in the command line.
endif
if !exists("g:system_echocmd")
    let g:system_echocmd = 0
endif

fun! WrapCmdLine(dispatcher) " {{{
    " a:dispatcher: is crdispatcher#CRDispatcher dict
    if a:dispatcher.cmdtype !=# ':' || a:dispatcher.ctrl_f
	" Do not fire with <c-f>
	return
    endif
    let cmdline = a:dispatcher.cmdline
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
	    let a:dispatcher.cmdline = "echo \"".cmd."\n\".system(\"".cmd."\")".his
	else
	    let a:dispatcher.cmdline = "echo system(\"".cmd."\")".his
	endif
    endif
endfun " }}}
try
    call add(crdispatcher#CRDispatcher['callbacks'], function('WrapCmdLine'))
catch /E121:/
    echohl ErrorMsg
    echom 'System Plugin: please install "https://github.com/coot/CRDispatcher".'
    echohl Normal
    finish
endtry
