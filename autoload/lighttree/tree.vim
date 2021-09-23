let s:tree = {}
let s:tree_list = []

function! lighttree#tree#get_tree_list()
    return s:tree_list
endfunction

function! lighttree#tree#get_id_list()
    let idlist = []
    for tree in tree_list
        call add(idlist, tree.id)
    endfor
    return idlist
endfunction

function! lighttree#tree#new(name = '')
    let tree = copy(s:tree)
    let tree.root = {}
    let tree.nodes = []
    let tree.nodes_open = []
    let tree.id = lighttree#util#get_next_id(s:tree_list)
    let tree.name = a:name
    call add(s:tree_list, tree)

    return tree
endfunction

function! s:tree.open(node)
    if !a:node.isinit
        let a:node.isinit = 1
        call self.init_node(a:node)
    endif
    if !a:node.isleaf
        let a:node.isopen = 1
        call add(self.nodes_open, a:node.id)
        call self.open_inter(a:node)
    else
        call self.open_leaf(a:node)
    endif
endfunction

function! s:tree.close(node)
    if !a:node.isleaf
        let a:node.isopen = 0
        call remove(self.nodes_open, index(self.nodes_open, a:node.id))
    endif
endfunction

function! s:tree.open_inter(node)
    if exists('a:node.action_open')
        call a:node.action_open()
    endif
    call lighttree#events#broadcast0('open_inter', a:node)
endfunction

function! s:tree.open_leaf(node)
    if exists('a:node.action_open')
        call a:node.action_open()
    endif
    call lighttree#events#broadcast0('open_leaf', a:node)
endfunction

function! s:tree.create(root)
    let self.root = a:root
    if self.name == ''
        let self.name = a:root.name
    endif
    let self.root.id = lighttree#util#get_next_id(self.nodes)
    call add(self.nodes, self.root)
    call self.init_node(self.root)
    if self.root.isopen
        call add(self.nodes_open, self.root.id)
    endif
endfunction

function! s:tree.add_node(node)
    if !exists('a:node.id')
        let a:node.id = lighttree#util#get_next_id(self.nodes)
    endif
    let parent = self.find_node(a:node.parent)
    call add(parent.children, a:node.id)
    call add(self.nodes, a:node)
    if a:node.isopen
        call add(self.nodes_open, a:node.id)
    endif
endfunction

function! s:tree.init_node(node)
    if exists('a:node.action_init')
        call a:node.action_init()
    endif
    call lighttree#events#broadcast0('init_node', a:node)
endfunction

function! s:tree.find_node(id)
    return lighttree#util#find_id(self.nodes, a:id)
endfunction

" sp_arg: 
"   arg:
"      0: return []
"      1: return all node
"      2: return node with mark
"   mark: mark name
function! s:tree.mount_tree_as_child(tree, parent, root, sp_arg = {'arg': 0}) abort
    let result = []
    let root = deepcopy(a:root)
    let root.children = []
    let children = copy(a:root.children)
    let root.parent = a:parent.id
    let root.id = lighttree#util#get_next_id(self.nodes)
    call self.add_node(root)
    if a:sp_arg.arg == 1 || (a:sp_arg.arg == 2 && exists('root[a:sp_arg.mark]') && root[a:sp_arg.mark])
        call add(result, root)
    endif
    if !root.isleaf
        for child_id in children
            let child = a:tree.find_node(child_id)
            let result_child = self.mount_tree_as_child(a:tree, root, child, a:sp_arg)
            let result += result_child
        endfor
    endif
    return result
endfunction

function! s:tree.getlength()
    return self.getlength_of_node(self.root)
endfunction

function! s:tree.getlength_of_node(node)
    let length = 1
    if a:node.isopen
        for id in a:node.children
            let child = self.find_node(id)
            let length += self.getlength_of_node(child)
        endfor
    endif
    return length
endfunction

" TODO: directory sort seems to not work
function! s:tree.sort(node)
    let Func_cp = function('lighttree#util#compare_func_for_str')
    if exists('self.compare_func')
        let Func_cp = self.compare_func
    endif

    function! s:insert_sort(name_list, id_list, func)
        let name_list = a:name_list
        let id_list = a:id_list
        if len(name_list) == 0
            return
        endif
        for i in range(1, len(name_list) - 1)
            let name0 = name_list[i]
            let id0 = id_list[i]
            let j = i-1
            while j >= 0 && a:func(name_list[j], name0) > 0
                let name_list[j + 1] = name_list[j]
                let id_list[j + 1] = id_list[j]
                let j -= 1
            endwhile
            let name_list[j + 1] = name0
            let id_list[j + 1] = id0
        endfor
    endfunction

    " leaf list
    let name_list0 = []
    let id_list0 = []
    " not leaf
    let name_list1 = []
    let id_list1 = []
    for child_id in a:node.children
        let child = self.find_node(child_id)
        if child.isleaf
            call add(name_list0, child.name)
            call add(id_list0, child.id)
        else
            call add(name_list1, child.name)
            call add(id_list1, child.id)
        endif
    endfor
    call s:insert_sort(name_list0, id_list0, Func_cp)
    call s:insert_sort(name_list1, id_list1, Func_cp)

    let a:node.children = id_list1 + id_list0
endfunction

function! s:tree.wrap_name(node)
    if exists('self.name_wrapper')
        return self.name_wrapper()
    else
        return s:wrap_name_default(self, a:node)
    endif
endfunction

function! s:wrap_name_default(tree, node)
    let sign_open = get(g:, 'lighttree_sign_open', '-')
    let sign_close = get(g:, 'lighttree_sign_close', '+')
    let sign_leaf = ' '
    let node = a:node
    let text = node.name
    let text = node.isleaf ? sign_leaf . ' ' . text :
                \ node.isopen ? sign_open . ' ' . text :
                \ sign_close . ' ' . text
    if !exists('a:node.parent') && node.name != a:tree.name
        let text .= ' ' . printf('[%s]', a:tree.name)
    endif
    return text
endfunction
