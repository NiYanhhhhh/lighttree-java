let g:lighttree#view#last_buffer = 0
let g:lighttree#view#last_winid = 0

function! lighttree#view#create_win(
            \   pos = get(g:, 'lighttree_win_pos', 'topleft'),
            \   size = get(g:, 'lighttree_win_size', [30, 25]),
            \   args = get(g:, 'lighttree_win_args', {'follow': ['nerdtree', 'lighttree', 'NvimTree']})
            \ ) abort
    let g:lighttree#view#last_buffer = bufnr()
    let g:lighttree#view#last_winid = win_getid()
    let winnr = -1
    if exists('a:args.follow')
        for bufname in a:args.follow
            let winnr = s:get_followed_winid(bufname)
            if winnr != -1
                break
            endif
        endfor
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
    nnoremap <buffer> <2-leftmouse> <cmd>call b:lighttree_ui.toggle(line('.'))<cr>
    nnoremap <buffer> o <cmd>call b:lighttree_ui.toggle(line('.'))<cr>
    nnoremap <buffer> s <cmd>call b:lighttree_ui.open(line('.'), {'flag': 'v'})<cr>
    nnoremap <buffer> i <cmd>call b:lighttree_ui.open(line('.'), {'flag': 'h'})<cr>
    nnoremap <buffer> t <cmd>call b:lighttree_ui.open(line('.'), {'flag': 't'})<cr>
    nnoremap <buffer> p <cmd>call b:lighttree_ui.focus_node_parent(line('.'))<cr>
    nnoremap <buffer> P <cmd>call b:lighttree_ui.focus_node_root(line('.'))<cr>
    nnoremap <buffer> J <cmd>call b:lighttree_ui.focus_node_last(line('.'))<cr>
    nnoremap <buffer> K <cmd>call b:lighttree_ui.focus_node_first(line('.'))<cr>
    nnoremap <buffer> <c-n> <cmd>call b:lighttree_ui.focus_node_middle(line('.'))<cr>
    nnoremap <buffer> <c-j> <cmd>call b:lighttree_ui.focus_node_next(line('.'))<cr>
    nnoremap <buffer> <c-k> <cmd>call b:lighttree_ui.focus_node_prev(line('.'))<cr>
    nnoremap <buffer> r <cmd>call b:lighttree_ui.refresh_node0(line('.'))<cr>
    nnoremap <buffer> R <cmd>call b:lighttree_ui.reload_node0(line('.'))<cr>
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
    let winnr = bufnr(a:name)
    if a:name == 'nerdtree'
        if exists('t:NERDTreeBufName')
            let winnr = bufwinnr(bufnr(t:NERDTreeBufName))
        endif
    elseif a:name == 'lighttree'
        if exists('t:lighttree_buffer')
            let winnr = bufwinnr(bufnr(t:lighttree_buffer))
        endif
    elseif a:name == 'NvimTree'
        let winnr = bufwinnr(bufnr("NvimTree_"))
    endif

    return winnr
endfunction

function! lighttree#view#opener_file(path, args = {})
    " call test#echowarn("== path ==========")
    " Ins a:path
    let flag = get(a:args, 'flag', 'e')
    " let winid = get(a:args, 'winid', g:lighttree#view#last_winid)

    " exec win_id2win(winid) . 'wincmd w'
    wincmd p
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
