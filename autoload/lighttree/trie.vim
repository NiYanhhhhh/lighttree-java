let s:trie = {}

" Sometimes trie can act as a tree
function! lighttree#trie#new(sep = '.')
    let trie = copy(s:trie)
    let trie.heads = []
    let trie.nodes = []
    let trie.sep = a:sep
    let trie.is_trie = 1

    return trie
endfunction

function! s:trie.add_node(node)
    if exists('a:node.parent')
        unlet a:node.parent
    endif
    let segment = split(a:node.name, '\.')
    let a:node.name = segment[-1]
    let child_start = 0
    let node_p = self.build_head(segment[0])

    for i in range(1, len(segment) - 1)
        let node = {}
        for id in node_p.children
            let child = self.find_node(id)
            if child.name == segment[i]
                let node = child
                break
            endif
        endfor
        if child_start || len(keys(node)) == 0
            let node = self.create_node(segment[i])
            let node.parent = node_p.id
            call add(node_p.children, node.id)
            let child_start = 1
        else
        endif
        let node_p = node
    endfor
    call extend(node_p, a:node, 'keep')
endfunction

function! s:trie.create_node(name, args = {})
    let node = extend({'name': a:name}, a:args, 'keep')
    let node = lighttree#util#wrap_node(node, 0)
    let node.id = lighttree#util#get_next_id(self.nodes)
    call add(self.nodes, node)

    return node
endfunction

function! s:trie.find(name)
    return lighttree#util#find(self.nodes, {'name': a:name})
endfunction

function! s:trie.build_head(name)
    let head = lighttree#util#find(self.heads, {'name': a:name})
    if len(keys(head)) == 0
        let head = self.create_node(a:name)
        call add(self.heads, head)
    endif
    return head
endfunction

function! s:trie.find_node(id)
    return lighttree#util#find_id(self.nodes, a:id)
endfunction

function! s:trie.compress()
    for head in self.heads
        call self.compress_node(head)
    endfor
endfunction

function! s:trie.compress_node(node)
    let node = a:node
    if len(node.children) == 1
        let child = self.find_node(node.children[0])
        let child.name = node['name'] . self.sep . child.name
        if exists('node.parent')
            let child.parent = node.parent
            let parent = self.find_node(node.parent)
            let parent.children[index(parent.children, node.id)] = child.id
        else
            unlet child.parent
            let self.heads[index(self.heads, node)] = child
        endif

        call self.compress_node(child)
    endif
endfunction

function! s:trie.get_heads()
    return self.heads
endfunction

function! s:trie.sort()
    
endfunction
