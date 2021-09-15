let s:handlers = {}

function! lighttree#events#construct(name, args)
    let event = {}
    let event.name = a:name
    let event.args = a:args
    return event
endfunction

function! lighttree#events#broadcast0(name, args)
    let event = lighttree#events#construct(a:name, a:args)
    call lighttree#events#broadcast(event)
endfunction

function! lighttree#events#broadcast(event)
    let ea = a:event.name
    for cb in s:handlers[ea]
        call cb(a:event.args)
    endfor
endfunction

function! lighttree#events#register_handler(event, callback)
    if !exists('s:handlers.event')
        call lighttree#log#echoerr("Event " . event . " is not registered!")
        return
    endif
    let handler = s:handlers.event
    call add(handler, a:callback)
endfunction

function! lighttree#events#register(event)
    if exists('s:handlers[a:event]')
        " call lighttree#log#echowarn("Event " . a:event . " exists!")
        return
    else
        let s:handlers[a:event] = []
    endif
endfunction
