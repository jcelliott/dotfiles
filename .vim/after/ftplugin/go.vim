" Settings for go files

let b:interpreter = 'go run'
setlocal makeprg = "go build %"

" don't show preview window for Go completions
" (it doesn't have any useful information)
setlocal completeopt-=preview

" use real tabs in Go sources
setlocal noexpandtab

" run file through goformat before saving
" already done in plugin
" autocmd BufWritePre *.go :silent Fmt
autocmd BufWritePre <buffer> :silent Fmt

map \i :Import 
map \d :Drop 

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

