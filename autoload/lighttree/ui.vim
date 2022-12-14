let g:lighttree_ui_no_last_line_sep = get(g:, 'lighttree_ui_no_last_line_sep', 1)
let g:lighttree_ui_line_sep = get(g:, 'lighttree_ui_line_sep', '')
let g:lighttree_ui_indent = get(g:, 'lighttree_ui_indent', 2)
let s:ui = {}

function! lighttree#ui#new(
            \   trees = [],
            \   opener = function('lighttree#view#opener_basic'),
            \   name_wrapper = function('lighttree#util#name_wrapper')
            \ )
    let ui = copy(s:ui)
    let ui.tree_list = a:trees
    let ui.linenr_map = [0]
    let ui.lastbuffer = 1
    let ui.indent = g:lighttree_ui_indent
    let ui.opener = a:opener

    return ui
endfunction

function! s:ui.set_opener(opener)
    let self.opener = a:opener
endfunction

function! s:ui.add_tree(tree)
    call add(self.tree_list, a:tree)
endfunction

function! s:ui.render()
    let currentline = 0
    for i in range(len(self.tree_list))
        let tree = self.tree_list[i]
        let line_expand = self.render_tree(tree, currentline)
        let currentline += line_expand

        if i != len(self.tree_list) - 1 || !g:lighttree_ui_no_last_line_sep
            call append(currentline, g:lighttree_ui_line_sep)
            let currentline += 1
            if type(g:lighttree_ui_line_sep) == type('')
                call insert(self.linenr_map, g:lighttree_ui_line_sep, currentline)
            else
                for i in range(len(g:lighttree_ui_line_sep))
                    call insert(self.linenr_map, g:lighttree_ui_line_sep[i], currentline)
                    let currentline += 1
                endfor
            endif
        endif
    endfor

    exec 'normal! Gddgg'
endfunction

function! s:ui.render_tree(tree, line_start)
    call append(a:line_start, a:tree.wrap_name(a:tree.root))
    let currentline = a:line_start + 1
    call insert(self.linenr_map, a:tree.root, currentline)
    if a:tree.root.isopen
        let line_expand = self.render_node(a:tree, a:tree.root, currentline, 0, 1)
        let currentline += line_expand
    endif
    return currentline - a:line_start
endfunction

function! s:ui.render_node(tree, node, currentline, depth, sp_arg = 0)
    let depth = a:depth + self.indent
    let linenr = a:currentline
    if !a:sp_arg
        call insert(self.linenr_map, a:node, linenr)
    endif
    let displaye_str_list = []
    for child_id in a:node.children
        let child = a:tree.find_node(child_id)
        call add(displaye_str_list, repeat(" ", depth) . a:tree.wrap_name(child))
    endfor
    call append(linenr, displaye_str_list)

    for child_id in a:node.children
        let child = a:tree.find_node(child_id)
        let linenr += 1
        let line_expand = 0
        if child.isopen
            let line_expand = self.render_node(a:tree, child, linenr, depth)
        else
            call insert(self.linenr_map, child, linenr)
        endif
        let linenr += line_expand
    endfor

    return linenr - a:currentline
endfunction

function! s:ui.open(linenr, args = {})
    setlocal modifiable
    let tree = self.gettree_from_linenr(a:linenr)
    let node = self.getnode_from_linenr(a:linenr)
    if node.isopen
        call lighttree#log#echowarn('This node cannot open now.')
        return
    endif
    let depth = self.getnode_depth(tree, node)
    call tree.open(node)
    if node.isleaf
        setlocal nomodifiable
        call self.opener(node, a:args)
    else
        call self.render_node(tree, node, a:linenr, depth, 1)
        call self.render_node_text(tree, node, a:linenr, depth)
        setlocal nomodifiable
    endif
endfunction

function! s:ui.getnode_from_linenr(linenr)
    return self.linenr_map[a:linenr]
endfunction

function! s:ui.gettree_from_linenr(linenr)
    let pos = 0
    for tree in self.tree_list
        let tree_len = tree.getlength()
        let pos += tree_len
        if pos >= a:linenr
            return tree
        endif
        if type(g:lighttree_ui_line_sep) == type('')
            let pos += 1
        else
            let pos += len(g:lighttree_ui_line_sep)
        endif
        if pos >= a:linenr
            return 0
        endif
    endfor
endfunction

function! s:ui.getnode_depth(tree, node)
    let depth = 0
    let node = a:node
    while exists('node.parent')
        let depth += self.indent
        let node = lighttree#util#find_id(a:tree.nodes, node.parent)
    endwhile
    return depth
endfunction

function! s:ui.close(linenr)
    setlocal modifiable
    let tree = self.gettree_from_linenr(a:linenr)
    let node = self.getnode_from_linenr(a:linenr)
    if !node.isopen
        call lighttree#log#echowarn('This node cannot close now')
        return
    endif
    if !node.isleaf
        call self.render_clear_child(tree, node, a:linenr)
    endif
    call tree.close(node)
    call self.render_node_text(tree, node, a:linenr)
    setlocal nomodifiable
endfunction

function! s:ui.render_clear_child(tree, node, currentline)
    let node_len = a:tree.getlength_of_node(a:node)
    let line_start = a:currentline + 1
    let line_end = a:currentline + node_len - 1
    if line_end < line_start
        echo '[lighttree]: This node has no child or not open.'
        return
    endif
    call remove(self.linenr_map, line_start, line_end)
    call deletebufline(bufname(), line_start, line_end)
endfunction

function! s:ui.toggle(linenr)
    let node = self.getnode_from_linenr(a:linenr)
    if node.isopen
        call self.close(a:linenr)
    else
        call self.open(a:linenr)
    endif
endfunction

function! s:ui.refresh_node0(linenr, in_order = 1)
    let tree = self.gettree_from_linenr(a:linenr)
    let node = self.getnode_from_linenr(a:linenr)
    call self.refresh_node(tree, node, a:linenr, a:in_order)
endfunction

function! s:ui.refresh_node(tree, node, currentline, in_order)
    setlocal modifiable
    let tree = a:tree
    let node = a:node
    let depth = self.getnode_depth(tree, node)
    call lighttree#events#broadcast0('refresh_node', node)
    if a:in_order
        call tree.sort(node)
    endif
    if node.isopen
        call self.render_clear_child(tree, node, a:currentline)
        call self.render_node(tree, node, a:currentline, depth, 1)
    endif
    call self.render_node_text(tree, node, a:currentline, depth)
    setlocal nomodifiable
endfunction

function! s:ui.reload_node(tree, node, currentline, in_order)
    setlocal modifiable
    let tree = a:tree
    let node = a:node
    let depth = self.getnode_depth(tree, node)
    call lighttree#events#broadcast0('reload_node', node)
    call self.render_clear_child(tree, node, a:currentline)
    call tree.reload(node)
    if node.isopen
        call self.render_node(tree, node, a:currentline, depth, 1)
    endif
    call self.render_node_text(tree, node, a:currentline, depth)
    call lighttree#log#echoinfo('node ' . node.name . ' reloaded!')
    setlocal nomodifiable
endfunction

function! s:ui.reload_node0(linenr, in_order = 1)
    let tree = self.gettree_from_linenr(a:linenr)
    let node = self.getnode_from_linenr(a:linenr)
    call self.reload_node(tree, node, a:linenr, a:in_order)
endfunction

function! s:ui.render_node_text(tree, node, currentline, depth = -1)
    let depth = a:depth
    if depth == -1
        let depth = self.getnode_depth(a:tree, a:node)
    endif
    let text = repeat(' ', depth) . a:tree.wrap_name(a:node)
    call setline(a:currentline, text)
endfunction

function! s:ui.focus_which(linenr, cb)
    let node = self.getnode_from_linenr(a:linenr)
    let tree = self.gettree_from_linenr(a:linenr)
    if !exists('node.parent')
        call lighttree#log#echoerr('Action error! no more parent node.')
        return
    endif
    let parent = tree.find_node(node.parent)
    try
        let next_id = a:cb(parent, node)
    catch /E684/
        call lighttree#log#echoerr('Action error! no such a node.')
        let next_id = parent.children[0]
    endtry
    let next_node = tree.find_node(next_id)
    exec 'normal ' . index(self.linenr_map, next_node) . 'gg'
endfunction

function! s:ui.focus_node_next(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node ->
                \ parent.children[index(parent.children, node.id) + 1]})
endfunction

function! s:ui.focus_node_prev(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node ->
                \ parent.children[index(parent.children, node.id) - 1]})
endfunction

function! s:ui.focus_node_middle(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node -> 
                \ parent.children[(len(parent.children) - 1) / 2]})
endfunction

function! s:ui.focus_node_first(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node -> parent.children[0]})
endfunction

function! s:ui.focus_node_last(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node -> parent.children[-1]})
endfunction

function! s:ui.focus_node_parent(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node -> parent.id})
endfunction

function! s:ui.focus_node_root(linenr = line('.'))
    call self.focus_which(a:linenr, {parent, node -> 0})
endfunction

function! s:ui.stress_node()
    
endfunction
