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
    let parent = lighttree#util#find_id_in(self.nodes, a:node.parent)
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
    return lighttree#util#find_id_in(self.nodes, a:id)
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

function! s:tree.sort(node)
    if exists('self.sorter')
        call self.sorter(a:node)
    else
        call s:sort_default(self, a:node)
    endif
endfunction

function! s:sort_default(tree, node)
    let name_list = []
    let sort_result = []
    for child_id in a:node.children
        let child = self.find_node(child_id)
        call add(name_list, child.name)
    endfor

endfunction

function! s:tree.wrap_name(node)
    if exists('self.name_wrapper')
        return self.name_wrapper()
    else
        return s:wrap_name_default(self, a:node)
    endif
endfunction

function! s:wrap_name_default(tree, node)
    let sign_open = get(g:, 'lighttree_default_sign_open', '-')
    let sign_close = get(g:, 'lighttree_default_sign_close', '+')
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
