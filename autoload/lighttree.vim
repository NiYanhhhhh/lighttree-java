" these fuctions is just for test """"""""""""""""""""""""""""""""""""
function! lighttree#get_node_data(args = {})
    let node = b:lighttree_ui.getnode_from_linenr(line('.'))
    let project_uri = b:lighttree_ui.gettree_from_linenr(line('.')).root.uri
    call extend(node, a:args, 'force')
    let data = lighttree#plugin#jdt#get_package_data(project_uri, node.kind, node)
    return data
endfunction

function! lighttree#get_node()
    return b:lighttree_ui.getnode_from_linenr(line('.'))
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

