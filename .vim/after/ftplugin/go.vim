" Settings for go files

let b:interpreter = 'go run'
setlocal makeprg = "go build %"

" don't show preview window for Go completions
" (it doesn't have any useful information)
" setlocal completeopt-=preview
" (but I like having the function signature stick around while I fill it in)

" use real tabs in Go sources
setlocal noexpandtab

nmap \i :GoImport<Space>
nmap \\i :GoImports<CR>
nmap \d :GoDrop<Space>
nmap <leader>r <Plug>(go-rename)

let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

