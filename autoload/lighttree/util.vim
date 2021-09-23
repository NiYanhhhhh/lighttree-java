" TODO: optimize
"   id system is too slow
function! lighttree#util#get_next_id_old(list)
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

function! lighttree#util#get_next_id(list, in_order = 0)
    if len(a:list) == 0
        return 0
    endif
    if a:in_order
        call lighttree#util#tidy_id_list(a:list)
    endif
    return a:list[-1].id + 1
endfunction

function! lighttree#util#find_id(list, id, in_order = 0)
    if a:in_order
        call lighttree#util#tidy_id_list(a:list)
    endif
    let target_id = a:id
    let target = a:list[target_id]
    while target.id != a:id
        let target_id -= 1
        if target_id < 0
            if a:in_order
                call lighttree#log#echoerr('id ' . a:id . ' not found!')
                return {}
            endif
            let target = lighttree#util#find_id(a:list, a:id, 1)
            return target
        endif
        let target = a:list[target_id]
    endwhile
    return target
endfunction

function! lighttree#util#find_id_old(list, id)
    return lighttree#util#find(a:list, {'id': a:id})
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

function! lighttree#util#find(list, obj)
    for obj in a:list
        let get = 1
        for [key, value] in items(a:obj)
            if obj[key] != value
                let get = 0
                break
            endif
        endfor
        if get
            return obj
        endif
    endfor
    return {}
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
    let tmp = a:path =~# 'jdt:/\+' ? a:path : resolve(a:path)
    return tmp =~# '.\+/$' ? substitute(tmp, '/$', '', '') : tmp
endfunction

function! lighttree#util#get_bufnr_of_filetype(filetype)
    let i = 1
    while 1
        if (bufloaded(i))
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
    if index1 + index2 > -2
        return index1 > index2 ? 1:
                    \ index1 < index2 ? -1: 0
    endif

    let index1 = 0
    let index2 = 0
    let index1 = a:str1[0] =~ '\u'
    let index2 = a:str2[0] =~ '\u'
    if index1 + index2 == 1
        return index1 - index2
    endif

    return a:str1 > a:str2 ? 1:
                \ a:str1 == a:str2 ? 0: -1
endfunction

