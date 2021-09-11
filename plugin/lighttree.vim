function! s:event_init()
    call lighttree#events#register('open_inter')
    call lighttree#events#register('open_leaf')
    call lighttree#events#register('init_node')
endfunction

function! s:config_init()
    let g:lighttree_win_pos= get(g:, 'lighttree_win_pos', 'topleft')
    let g:lighttree_win_size= get(g:, 'lighttree_win_size', [30, 25])
    let g:lighttree_win_args= get(g:, 'lighttree_win_args', {'follow': 'nerdtree'})
endfunction

function! s:command_init()
endfunction

function! s:main()
    call s:event_init()
    call s:config_init()
endfunction

call s:main()
