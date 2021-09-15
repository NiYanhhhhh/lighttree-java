function! lighttree#util#get_next_id(list)
    let is_get = 0
    let max_id = 0
    for obj in a:list
        if obj.id > max_id
            let max_id = obj.id
        endif
    endfor
    if max_id == len(a:list)
        return max_id + 1
    elseif max_id < len(a:list)
        throw "there are duplicated id in list!"
    endif

    for i in range(len(a:list))
        let is_get = 1
        for obj in a:list
            if obj.id == i
                let is_get = 0
                break
            endif
        endfor
        if is_get
            return i
        endif
    endfor
    return max_id + 1
endfunction

function! lighttree#util#tidy_id_list(list)
    for i in range(1, len(a:list))
        let can = a:list[i]
        for j in range(0, i)
            if can.id < a:list[j].id
                let a:list[j+1] = a:list[j]
            else
                let a:list[j+1] = can
                break
            endif
        endfor
    endfor

    " for i in range(len(a:list))
        " if i != a:list[i].id
            " let a:list[i].id = i
        " endif
    " endfor
endfunction

function! lighttree#util#find_id_in(list, id)
    for obj in a:list
        if obj.id == a:id
            return obj
        endif
    endfor
endfunction

" what keys does a valid node needs?
" name:     displayed string for a node (highlight function is in WIP)
" isopen:   a value to show if its children should be rendered
" isleaf:   a value to show if this node is a leafnode
function! lighttree#util#wrap_node(node, isleaf = 1, isopen = 0)
    let a:node.children = get(a:node, 'children', [])
    let a:node.name = get(a:node, 'name', '')
    let a:node.isopen = get(a:node, 'isopen', a:isopen)
    let a:node.isleaf = get(a:node, 'isleaf', a:isleaf)
    let a:node.isinit = 0
    let a:node.attribute = {}
    return a:node
endfunction

function! lighttree#util#get_next_bufnr()
    if !exists('s:lighttree_bufnr_now')
        let s:lighttree_bufnr_now = 1
    else
        let s:lighttree_bufnr_now += 1
    endif

    return s:lighttree_bufnr_now
endfunction

" This function is stolen from nerdtree
function! lighttree#util#resolve(path)
    let tmp = resolve(a:path)
    return tmp =~# '.\+/$' ? substitute(tmp, '/$', '', '') : tmp
endfunction

function! lighttree#util#get_bufnr_of_filetype(filetype)
    let i = 0
    while 1
        if (bufexists(i) || i == 0)
            let name = bufname(i)
            if fnamemodify(name, ":e") == a:filetype
                return bufnr(name)
            endif
        endif
        let i = i + 1
    endwhile

    return 0
endfunction

function! lighttree#util#compare_func_for_str(str1, str2)
    let l_end = ["JRE System Library", "Dependencies"]
    let index1 = -1
    let index2 = -1
    for i in range(len(l_end))
        let index1 = a:str1 =~# l_end[i] ? i : index1
        let index2 = a:str2 =~# l_end[i] ? i : index2
    endfor
    if index1 > index2
        return 1
    elseif index1 < index2
        return -1
    endif

    if index1 == index2 && index1 != -1
        return 0
    endif

    return a:str1 > a:str2 ? 1:
                \ a:str1 == a:str2 ? 0: -1
endfunction

