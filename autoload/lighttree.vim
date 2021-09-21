" these fuctions is just for test """"""""""""""""""""""""""""""""""""
function! lighttree#get_node_data(args = {})
    let node = b:lighttree_ui.getnode_from_linenr(line('.'))
    let project_uri = b:lighttree_ui.gettree_from_linenr(line('.')).root.uri
    let args = extend(deepcopy(node), a:args, 'force')
    let data = lighttree#plugin#jdt#get_package_data(project_uri, node.kind, args)
    return data
endfunction

function! lighttree#get_node()
    return b:lighttree_ui.getnode_from_linenr(line('.'))
endfunction

function! lighttree#show_linenr_map()
    call lighttree#log#echo('show linenr map ==========')
    for line in b:lighttree_ui.linenr_map
        if type(line) != type({})
            echom string(line)
        else
            echom line.name . ' isopen: ' . line.isopen
        endif
    endfor
    call lighttree#log#echo('end ======================')
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

