" Settings for markdown files

setlocal textwidth=100
set formatoptions=tcqn  " settings for formatting (see :help fo-table)

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
