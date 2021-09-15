let g:lighttree#view#last_buffer = 0
let g:lighttree#view#last_winid = 0

function! lighttree#view#create_win(
            \   pos = get(g:, 'lighttree_win_pos', 'topleft'),
            \   size = get(g:, 'lighttree_win_size', [30, 25]),
            \   args = get(g:, 'lighttree_win_args', {'follow': 'nerdtree'})
            \ ) abort
    let g:lighttree#view#last_buffer = bufnr()
    let g:lighttree#view#last_winid = win_getid()
    let winnr = -1
    if exists('a:args.follow')
        let winnr = s:get_followed_winid(a:args.follow)
    endif

    if winnr != -1
        exec winnr . 'wincmd w'
        exec a:size[1] . 'split new'
    else
        exec a:pos . ' vertical ' . a:size[0] . ' new'
        exec 'vertical resize ' . a:size[0]
    endif

    setlocal winfixwidth
    setlocal winfixheight

    return win_getid()
endfunction

function! lighttree#view#close_win()
    let winnr = winnr()
    " call win_gotoid(g:lighttree#view#last_winid)
    exec 'wincmd p'
    exec winnr.'wincmd q'
endfunction

function! lighttree#view#setup_buffer()
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nofoldenable
    setlocal nolist
    setlocal nospell
    setlocal nowrap
    setlocal nonumber
    setlocal nocursorcolumn
    if v:version >= 703
        setlocal norelativenumber
    endif

    setlocal filetype=lighttree
endfunction

function! lighttree#view#common_map()
    nnoremap <buffer> q <cmd>call lighttree#view#close_win()<cr>
    nnoremap <buffer> <cr> <cmd>call b:lighttree_ui.toggle(line('.'))<cr>
    nnoremap <buffer> o <cmd>call b:lighttree_ui.toggle(line('.'))<cr>
    nnoremap <buffer> s <cmd>call b:lighttree_ui.open(line('.'), {'flag': 'v'})<cr>
    nnoremap <buffer> i <cmd>call b:lighttree_ui.open(line('.'), {'flag': 'h'})<cr>
    nnoremap <buffer> t <cmd>call b:lighttree_ui.open(line('.'), {'flag': 't'})<cr>
    nnoremap <buffer> r <cmd>call b:lighttree_ui.refresh_node0(line('.'))<cr>
endfunction

function! lighttree#view#opener_basic(node, args = {})
    let node = a:node
    let text = node['name'] . ' opened! '
    if exists('a:args.info')
        let info = a:args.info
        let text .= '['.info.']'
    endif
    call lighttree#log#echowarn(text)
endfunction

function! s:get_followed_winid(name)
    let winnr = -1
    if a:name == 'nerdtree'
        if exists('t:NERDTreeBufName')
            let winnr = bufwinnr(bufnr(t:NERDTreeBufName))
        endif
    endif

    return winnr
endfunction

function! lighttree#view#opener_file(path, args = {})
    let flag = get(a:args, 'flag', 'e')
    let winid = get(a:args, 'winid', g:lighttree#view#last_winid)

    exec win_id2win(winid) . 'wincmd w'
    if flag == 'v'
        exec 'vsplit `=' . string(a:path) . '`'
    elseif flag == 'h'
        exec 'split `=' . string(a:path) . '`'
    elseif flag == 'e'
        exec 'edit `=' . string(a:path) . '`'
    elseif flag == 't'
        exec 'tabnew `=' . string(a:path) . '`'
    endif
endfunction
