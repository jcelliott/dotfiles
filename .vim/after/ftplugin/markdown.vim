" Settings for markdown files

set tabstop=4
set softtabstop=4
set shiftwidth=4

setlocal textwidth=80
" set formatoptions=tqan  " settings for formatting (see :help fo-table)
set formatoptions=tcqn  " settings for formatting (see :help fo-table)

" enable spell check
setlocal spell

" let g:tagbar_type_markdown = {
"   \ 'ctagstype' : 'markdown',
"   \ 'kinds' : [
"     \ 'h:Heading_L1',
"     \ 'i:Heading_L2',
"     \ 'k:Heading_L3'
"   \ ]
" \ }

" if executable('marktag')
"     let g:tagbar_type_markdown = {
"         \ 'ctagstype' : 'markdown',
"         \ 'ctagsbin' : 'marktag',
"         \ 'kinds' : [
"             \ 'h:header'
"         \ ],
"         \ 'sro' : '.',
"         \ 'kind2scope' : {
"             \ 'h' : 'header'
"         \  },
"         \ 'scope2kind' : {
"             \ 'header' : 'h'
"         \ }
"     \ }
" end
