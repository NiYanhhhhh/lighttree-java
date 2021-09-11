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
