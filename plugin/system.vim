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
    let a:dispatcher.state = 2
    if a:dispatcher.cmdtype !=# ':' || a:dispatcher.ctrl_f
	" Do not fire with <c-f>
	return
    endif
    let cmd = a:dispatcher.cmd
    let cmdline = cmd.cmd
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
	let _cmd = escape(cmd, "\"")
	let _his = "|call histdel(':', -1)"
	if g:system_echocmd
	    let cmd.cmd = "echo \""._cmd."\n\".system(\""._cmd."\")"._his
	else
	    let cmd.cmd = "echo system(\""._cmd."\")"._his
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
