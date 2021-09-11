function! s:ui_test()
    let tree = lighttree#tree#new()
    let tree1 = lighttree#tree#new()
    let ui = lighttree#ui#new()
    call ui.add_tree(tree)
    call ui.add_tree(tree1)

    let root = {'name': 'root'}
    call lighttree#util#wrap_node(root)
    let root.isleaf = 0
    let root.isopen = 1

    call tree.create(root)

    let child1 = {'name': 'child1'}
    call lighttree#util#wrap_node(child1)
    let child1.isleaf = 0
    let child1.parent = root.id
    let child1.isopen = 1
    call tree.add_node(child1)
    let child2 = {'name': 'child2'}
    call lighttree#util#wrap_node(child2)
    let child2.isleaf = 0
    let child2.parent = root.id
    let child2.isopen = 0
    call tree.add_node(child2)
    let child3 = {'name': 'child3'}
    call lighttree#util#wrap_node(child3)
    let child3.isleaf = 0
    let child3.parent = child1.id
    let child3.isopen = 1
    call tree.add_node(child3)

    let leaf0 = {'name': 'leaf0'}
    let leaf0.parent = root.id
    call lighttree#util#wrap_node(leaf0)
    let leaf1 = {'name': 'leaf1'}
    let leaf1.parent = root.id
    call lighttree#util#wrap_node(leaf1)
    call tree.add_node(leaf0)
    call tree.add_node(leaf1)

    let leaf2 = {'name': 'leaf2'}
    call lighttree#util#wrap_node(leaf2)
    let leaf2.parent = child1.id
    let leaf3 = {'name': 'leaf3'}
    call lighttree#util#wrap_node(leaf3)
    let leaf3.parent = child2.id
    let leaf4 = {'name': 'leaf4'}
    call lighttree#util#wrap_node(leaf4)
    let leaf4.parent = child3.id
    call tree.add_node(leaf2)
    call tree.add_node(leaf3)
    call tree.add_node(leaf4)

    let root1 = {'name': 'root1'}
    call lighttree#util#wrap_node(root1)
    let root1.isleaf = 0
    let root1.isopen = 1

    call tree1.create(root1)

    let win_id = lighttree#view#create_win()
    exec 'edit lighttree_' . lighttree#util#get_next_bufnr()
    call lighttree#view#setup_buffer()
    call lighttree#view#common_map()
    if exists('b:lighttree_ui')
        unlet b:lighttree_ui
    endif
    let b:lighttree_ui = ui

    call ui.render()
    setlocal nomodifiable
endfunction

call s:ui_test()
