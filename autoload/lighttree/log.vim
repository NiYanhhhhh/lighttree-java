function! lighttree#log#echo(msg, r = 1)
    let msg = s:wrap_msg(a:msg)
    if a:r
        echom msg
    else
        echo msg
    endif
endfunction

function! lighttree#log#echoerr(msg)
    let msg = s:wrap_msg(a:msg)
    echoerr msg
endfunction

function! lighttree#log#echowarn(msg)
    echohl WarningMsg
    call lighttree#log#echo(a:msg)
    echohl None
endfunction

function! lighttree#log#echoinfo(msg)
    echohl Question
    call lighttree#log#echo(a:msg, 0)
    echohl None
endfunction

function! s:wrap_msg(content)
    let content = '[lighttree]: ' . a:content
    return content
endfunction
