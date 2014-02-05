# System Vim Plugin

This is a tiny vim script which might have been discovered ages ago (but I am
unaware). Its rather for vim than gvim users.

When executing commands from vim you enter a vim shell where you see the
output. In many situations this is not what you want and you'd prefer 

    :call system("command")

but it is a lot to type, and you don't have completion. With this snippet
every command which starts with:

    :! command

(note the space after the "!") will be wrapped into system() and the output will be
echoed. The plugin refreshes the history with what you typed rather than the
call to the system() function.

There are some configuration variables:

    g:system_expand = 1

by default % (with modifiers) is expanded in the same way as by the :!.

    g:system_echocmd = 0

echo the command together with its output (by default off).

The reason why I like it is that I have different background colors in vim
(dark) and terminal (light). If I stay inside vim I am not flushed with
bright colors which is a annoying (and may be eyes tiring).

Benefits: you get completion for system commands and system files.

You can use the expression register with Vim 7.3.686.


# Requirements
You have to also install [crdispatch](https://github.com/coot/CRDispatcher)
plugin.

I learned how to do that reading the emacscommandline plugin.

Other plugins with shell like functionality:
* [vim-addon-async](https://github.com/MarcWeber/vim-addon-async)
* [Conque Shell plugin](http://code.google.com/p/conque)
* [vimproc plugin](http://github.com/Shougo/vimproc/tree/master/doc/vimproc.txt)


## Copyright
© Marcin Szamotulski, 2012-2014

## License
Vim license, see :help license
