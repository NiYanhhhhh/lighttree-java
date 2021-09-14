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
    call append(a:line_start, a:tree.name)
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
        call add(displaye_str_list, repeat(" ", depth) . child.name)
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
        call self.opener(node, a:args)
    else
        call self.render_node(tree, node, a:linenr, depth, 1)
    endif
    setlocal nomodifiable
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
        let node = lighttree#util#find_id_in(a:tree.nodes, node.parent)
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
    setlocal nomodifiable
endfunction

function! s:ui.render_clear_child(tree, node, currentline)
    let node_len = a:tree.getlength_of_node(a:node)
    let line_start = a:currentline + 1
    let line_end = a:currentline + node_len - 1
    if line_end < line_start
        echo '[lighttree]: This node has no child'
        return
    endif
    call remove(self.linenr_map, line_start, line_end)
    call deletebufline(t:lighttree_buffer, line_start, line_end)
endfunction

function! s:ui.toggle(linenr)
    let node = self.getnode_from_linenr(a:linenr)
    if node.isopen
        call self.close(a:linenr)
    else
        call self.open(a:linenr)
    endif
endfunction

function! s:ui.refresh_node(tree, node, currentline, in_order)
    let tree = a:tree
    let node = a:node
    let depth = self.getnode_depth(node)
    call lighttree#events#broadcast0('refresh_node', node)
    if a:in_order
        call tree.sort(node)
    endif
    if node.isopen
        call self.render_clear_child(tree, node, a:currentline)
        call self.render_node(tree, node, a:currentline, depth, 1)
    endif
endfunction

