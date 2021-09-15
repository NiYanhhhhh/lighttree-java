function! s:event_init()
    call lighttree#events#register('open_inter')
    call lighttree#events#register('open_leaf')
    call lighttree#events#register('init_node')
    call lighttree#events#register('refresh_node')
endfunction

function! s:config_init()
    let g:lighttree_win_pos = get(g:, 'lighttree_win_pos', 'topleft')
    let g:lighttree_win_size = get(g:, 'lighttree_win_size', [30, 25])
    let g:lighttree_win_args = get(g:, 'lighttree_win_args', {'follow': 'nerdtree'})
    let g:lighttree_default_sign_open = get(g:, 'lighttree_default_sign_open', '-')
    let g:lighttree_default_sign_close = get(g:, 'lighttree_default_sign_close', '+')

    let g:lighttree_java_ishierarchical = get(g:, 'lighttree_java_ishierarchical', v:false)
    let g:lighttree_java_request_timeout = get(g:, 'lighttree_java_request_timeout', 500)
    let g:lighttree_java_server_name = get(g:, 'lighttree_java_server_name', 'jdt.ls')
endfunction

function! s:autocmd_init()
endfunction

function! s:command_init()
endfunction

function! s:main()
    call s:event_init()
    call s:config_init()
endfunction

call s:main()
