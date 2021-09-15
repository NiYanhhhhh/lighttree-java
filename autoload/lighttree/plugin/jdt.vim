let g:lighttree_jdt_win_pos = get(g:, 'lighttree_win_pos', 'topleft')
let g:lighttree_jdt_win_size = get(g:, 'lighttree_win_size', [30, 25])
let g:lighttree_jdt_win_args = get(g:, 'lighttree_win_args', {'follow': 'nerdtree'})

let s:middle_symbol = '_(:3_r_/_)_'
let s:node_kind = {
            \   "Workspace": 1,
            \   "Project": 2,
            \   "Container": 3,
            \   "PackageRoot": 4,
            \   "Package": 5,
            \   "PrimaryType": 6,
            \   "Folder": 7,
            \   "File": 8
            \ }

let s:type_kind = {
            \   "Class": 1,
            \   "Interface": 2,
            \   "Enum": 3
            \ }

let s:entry_kind = {
            \   "CPE_LIBRARY": 1,
            \   "CPE_PROJECT": 2,
            \   "CPE_SOURCE": 3,
            \   "CPE_VARIABLE": 4,
            \   "CPE_CONTAINER": 5
            \ }

let s:njd = 'require("nvim-java-dependency.sync_command").'

function! lighttree#plugin#jdt#get_projects(url, callback = 'a')
    let projects = luaeval(s:njd.'get_projects({_A})', a:url)

    " TODO: caches
    if exists('*'.a:callback)
        call function(a:callback)
    endif

    return projects
endfunction

function! lighttree#plugin#jdt#resolve_path(url, callback = 'a')
    let result = luaeval(s:njd.'resolve_path({_A})', a:url)
    if exists('*'.a:callback)
        call function(a:callback)
    endif
    return result
endfunction

function! lighttree#plugin#jdt#get_package_data(project_uri, kind = 2, args = {}, callback = 'a')
    let args = {"kind": a:kind, "projectUri": a:project_uri}
    call extend(args, a:args, "force")
    let result = luaeval(s:njd.'get_package_data(_A)', args)

    " TODO: caches
    if exists('*'.a:callback)
        call function(a:callback)
    endif

    return result
endfunction

" WIP
" need optimizing
function! lighttree#plugin#jdt#find_root_node(path)
    let url = lighttree#plugin#jdt#string_to_url(a:path)
    let result = lighttree#plugin#jdt#resolve_path(url)
    if type(result) == type(v:null) || len(result) == 0 || type(result[0]) == type(v:null)
        return lighttree#plugin#jdt#stringToPath(a:path)
    endif

    let project_url = result[0].uri
    let project_path = lighttree#plugin#jdt#url_to_string(project_url)
    let project_path = lighttree#util#resolve(project_url)
    let parent_path = fnamemodify(project_path, '%:h')
    let projects = lighttree#plugin#jdt#get_projects(lighttree#plugin#jdt#string_to_url(parent_path.str()))
    if len(projects) > 1
        let root_path = parent_path
    endif

    return root_path
endfunction

function! lighttree#plugin#jdt#url_to_string(url)
    let url_pattern = 'file:/\+'
    let root = '/'

    let url = a:url
    let path = substitute(url, url_pattern, root, '')
    if path !=# '/'
        let path = lighttree#util#resolve(path)
    endif
    return path
endfunction

function! lighttree#plugin#jdt#string_to_url(str)
    if a:str !=# '/'
        let str = lighttree#util#resolve(a:str)
    endif
    return 'file://' . str
endfunction

function! lighttree#plugin#jdt#open_win(
            \   pos = g:lighttree_jdt_win_pos,
            \   size = g:lighttree_jdt_win_size,
            \   args = g:lighttree_jdt_win_args
            \ )
    let url = lighttree#plugin#jdt#string_to_url(getcwd())
    let projects = lighttree#plugin#jdt#get_projects(url)
    let ui = lighttree#ui#new()
    call ui.set_opener(function('s:opener'))
    for i in range(len(projects))
        let tree = lighttree#tree#new()
        let root = lighttree#util#wrap_node(projects[i], 0, 1)
        call tree.create(root)
        call s:create_root_child(tree, root)
        call ui.add_tree(tree)
    endfor

    let win_id = s:create_win(a:pos, a:size, a:args)
    if exists('b:lighttree_ui')
        unlet b:lighttree_ui
    endif
    let b:lighttree_ui = ui
    call ui.render()
    setlocal nomodifiable
    let &statusline='Java Dependency'
endfunction

function! lighttree#plugin#jdt#close_win()
    let winnr = lighttree#plugin#jdt#focus_win()
    if winnr
        call lighttree#view#close_win()
    endif
endfunction

function! lighttree#plugin#jdt#focus_win()
    let winnr = lighttree#plugin#jdt#exists_win()
    if winnr
        exec winnr.'wincmd w'
    endif
    return winnr
endfunction

function! lighttree#plugin#jdt#exists_win()
    if !exists('t:lighttree_buffer')
        call lighttree#plugin#jdt#open_win()
        return 0
    else
        let winlist = win_findbuf(bufnr(t:lighttree_buffer))
        if len(winlist) == 0
            return 0
        else
            return win_id2win(winlist[0])
        endif
    endif
endfunction

function! lighttree#plugin#jdt#toggle_win(
            \   pos = g:lighttree_jdt_win_pos,
            \   size = g:lighttree_jdt_win_size,
            \   args = g:lighttree_jdt_win_args
            \ )
    if !exists('t:lighttree_buffer')
        call lighttree#plugin#jdt#open_win()
        return
    endif

    let winnr = lighttree#plugin#jdt#exists_win()
    if winnr
        call lighttree#plugin#jdt#close_win()
    else
        call lighttree#view#create_win(a:pos, a:size, a:args)
        exec 'buffer ' . t:lighttree_buffer
    endif
endfunction

function! s:create_win(...)
    let win_id = call('lighttree#view#create_win', a:000)
    let t:lighttree_buffer = 'lighttree_' . lighttree#util#get_next_bufnr()
    exec 'edit ' . t:lighttree_buffer
    call lighttree#view#setup_buffer()
    call lighttree#view#common_map()
    return win_id
endfunction

function! s:create_child(tree, node, kind)
    let kind = a:kind
    if kind == s:node_kind.Container
        call s:create_container_child(a:tree, a:node)
    elseif kind == s:node_kind.PackageRoot
        call s:create_packageroot_child(a:tree, a:node)
    elseif kind == s:node_kind.Package
        call s:create_package_child(a:tree, a:node)
    elseif kind == s:node_kind.Folder
        call s:create_folder_child(a:tree, a:node)
    " elseif kind == s:node_kind.PrimaryType
    " elseif kind == s:node_kind.File
    endif
    call a:tree.sort(a:node)
endfunction

function! s:create_root_child(tree, node) abort
    call lighttree#log#echoinfo("Indexing...")
    let response = lighttree#plugin#jdt#get_package_data(a:node.uri)
    let root_data = []
    for item in response
        if item.entryKind == s:entry_kind.CPE_SOURCE
            let package_roots = lighttree#plugin#jdt#get_package_data(a:node.uri, s:node_kind.Container, {'path': item.path})
            call extend(root_data, package_roots)
            continue
        endif
        call add(root_data, item)
    endfor
    for item in root_data
        if item.kind == s:node_kind.Container
            let item = lighttree#util#wrap_node(item, 0)
            let item.parent = a:node.id
            call a:tree.add_node(item)

            call s:create_child(a:tree, item, item.kind)
        endif
    endfor
endfunction

function! s:create_container_child(tree, node)
    let response = lighttree#plugin#jdt#get_package_data(a:tree.root.uri, 3, a:node)
    let child_list = s:handle_response(response, a:node)
    for child in child_list
        call a:tree.add_node(child)
        let child.action_init = function('s:create_child', [a:tree, child, child.kind])
    endfor
endfunction

function! s:create_packageroot_child(tree, node)
    call lighttree#log#echoinfo("Indexing ".a:node.name."...")
    let args = extend(a:node, { 'isHierarchicalView': g:lighttree_java_ishierarchical})
    let response = lighttree#plugin#jdt#get_package_data(a:tree.root.uri, 4, args)
    let child_list = s:handle_response(response, a:node)
    for child in child_list
        call a:tree.add_node(child)
        " call s:create_child(a:tree, child, child.kind)
        let child.action_init = function('s:create_child', [a:tree, child, child.kind])
    endfor
endfunction

function! s:create_package_child(tree, node)
    let args = extend(a:node, { 'isHierarchicalView': g:lighttree_java_ishierarchical})
    let response = lighttree#plugin#jdt#get_package_data(a:tree.root.uri, 5, args)
    let child_list = s:handle_response(response, a:node)
    for child in child_list
        call a:tree.add_node(child)
        " call s:create_child(a:tree, child, child.kind)
        let child.action_init = function('s:create_child', [a:tree, child, child.kind])
    endfor
endfunction

" function! s:create_primarytype_child(tree, node)
    " let response = lighttree#plugin#jdt#get_package_data(a:tree.root.uri, 3, a:node)
    " let child_list = s:handle_response(response, a:node)
    " for child in child_list
        " call a:tree.add_node(child)
        " call s:create_child(a:tree, child, child.kind)
    " endfor
" endfunction

function! s:create_folder_child(tree, node)
    let response = lighttree#plugin#jdt#get_package_data(a:tree.root.uri, 7, a:node)
    let child_list = s:handle_response(response, a:node)
    for child in child_list
        call a:tree.add_node(child)
        call s:create_child(a:tree, child, child.kind)
    endfor
endfunction

function! s:handle_response(response, parent)
    let child_list = []
    for item in a:response
        let item = lighttree#util#wrap_node(item, 0)
        let item.parent = a:parent.id
        if item.kind == s:node_kind.PrimaryType
            if !exists('item.metaData') ||
                        \ !exists('item.metaData.TypeKind') ||
                        \ !item.metaData.TypeKind
                continue
            endif
            let item.isleaf = 1
        elseif item.kind == s:node_kind.File
            let item.isleaf = 1
        endif

        call add(child_list, item)
    endfor

    return child_list
endfunction

function! s:opener(node, args)
    let path = a:node.uri
    call lighttree#view#opener_file(path, a:args)
endfunction
