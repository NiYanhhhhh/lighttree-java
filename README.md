# lighttree-java

A java dependency exloperor using neovim build-in lsp and [vscode-java-dependency](4) bundle.

## Installation

Requires:

- [neovim](1) (version $\ge$ 0.5)
- running jdtls ([nvim-jdtls](2) is recommended)

Configuration:

- get [vscode-java-dependency](4) jdtls extension bundle
    1. Download the vscode extension [Project Manager for Java](https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-dependency/0.18.7/vspackage)
    2. Extract file `com.microsoft.jdtls.ext.core-0.18.7.jar` in `archive_root:/extension/server/` from the vsix pack to wherever you like

    You can also build it manually from the [git repository](4):

        git clone https://github.com/microsoft/vscode-java-dependency
        cd vscode-java-dependency/jdtls.ext
        ./mvnw clean package

    As it returns `BUILD SUCCESS`, the jar pack will be at `vscode-java-dependency/jdtls.ext/com.microsoft.jdtls.ext.core/target/com.microsoft.jdtls.ext.core-${version}.jar`

- extend the initializationOptions with which you start [eclipse.jdt.ls](3) as follows:

    ```lua
    --- example when using nvim-jdtls
    local config = {}
    local bundles = vim.fn.glob("/path/to/jar/com.microsoft.jdtls.ext.core-*.jar")
    config['init_options']
    ---
    --- your settings
    ---
    require('jdtls').start_or_attach(config)
    ```

## Feature

![feature](https://raw.githubusercontent.com/NiYanhhhhh/lighttree-java/master/screenshots/Peek%202021-09-16%2020-00.gif)

- configuration

    ```vim
    "-- variables and its default value:
    " lighttree window position (available: 'topleft', 'botright')
    let g:lighttree_win_pos = 'topleft'
    " lighttree window size ([width, height])
    let g:lighttree_win_size = [30, 25]
    " this setting makes the window appear below the opening nerdtree window, set to empty dict to disable it
    let g:lighttree_win_args = {'follow': 'nerdtree'}
    " indicator show before the directory node (when opening)
    let g:lighttree_default_sign_open = '-'
    " indicator show before the directory node (when closing)
    let g:lighttree_default_sign_close = '+'

    " [WIP] decide the appearance of java package in explorer (reference to eclipse project explorer)
    let g:lighttree_java_ishierarchical = v:false
    " this plugin uses sync request, this option decides the timeout the client waits
    let g:lighttree_java_request_timeout = 500
    " you java language server name (which is 'jdt.ls in nvim-jdtls')
    let g:lighttree_java_server_name = 'jdt.ls'

    "-- default maps
    " lighttree buffer:
    "close node
    nnoremap <buffer> q <cmd>call lighttree#view#close_win()<cr>
    "toggle node
    nnoremap <buffer> <cr> <cmd>call b:lighttree_ui.toggle(line('.'))<cr>
    nnoremap <buffer> o <cmd>call b:lighttree_ui.toggle(line('.'))<cr>
    "open leaf node using vsplit
    nnoremap <buffer> s <cmd>call b:lighttree_ui.open(line('.'), {'flag': 'v'})<cr>
    "open leaf node using split
    nnoremap <buffer> i <cmd>call b:lighttree_ui.open(line('.'), {'flag': 'h'})<cr>
    "open leaf node in new tab
    nnoremap <buffer> t <cmd>call b:lighttree_ui.open(line('.'), {'flag': 't'})<cr>
    "refresh node
    nnoremap <buffer> r <cmd>call b:lighttree_ui.refresh_node0(line('.'))<cr>

    " map a function to start (not do in the plugin):
    " nnoremap <silent> <leader><f3> <cmd>call lighttree#plugin#jdt#toggle_win()<cr>
    ```


## Story
At first I try to hack [nerdtree](6) to achieve my goal. However it takes too many time and works not good. Maybe it's a bit hard for me. So I just write a extensible and easy-to-use ui api and it even takes me less time and seems to works good. This api, lighttree, is in the autoload directory, where you can see the source.

Nerdtree is a wonderful plugin. I use it for a long time.

Beacause I'm struggling for my university education, so there is no time to write the document for me and even this plugin will be update slowly.

Millions of thanks to contributors!

## License
MIT License.



[1]: https://github.com/neovim/neovim
[2]: https://github.com/mfussenegger/nvim-jdtls
[3]: https://github.com/eclipse/eclipse.jdt.ls
[4]: https://github.com/microsoft/vscode-java-dependency
[5]: https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-dependency/0.18.7/vspackage
[6]: https://github.com/preservim/nerdtree
