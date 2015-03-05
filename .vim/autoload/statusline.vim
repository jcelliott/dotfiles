" custom statusline
" used when airline isn't installed

if exists('g:loaded_statusline')
  finish
endif
let g:loaded_statusline = 1

function! statusline#load_statusline()
  " Set initial statusline highlights
  hi statusline ctermbg=19 ctermfg=20
  hi User1 ctermbg=19 ctermfg=0  "buffer number
  hi User2 ctermbg=19 ctermfg=1  "filetype
  hi User3 ctermbg=19 ctermfg=4  "fugitive(git)
  hi User4 ctermbg=1  ctermfg=7  "syntastic
  hi User5 ctermbg=19 ctermfg=2  "virtualenv

  " define autocmds
  augroup StatuslineHighlight
    autocmd!
    autocmd InsertEnter * :call statusline#set_insert_statusline()
    autocmd InsertLeave * :call statusline#clear_insert_statusline()
  augroup END

  " Statusline formatting                       (Remember to escape spaces '\ ')
  set statusline=
  set statusline+=%1*[%n]%*                     " buffer number
  set statusline+=\ %F                          " full filename
  set statusline+=\ %2*                         " switch to User2 highlight
  set statusline+=%y                            " filetype
  set statusline+=%*                            " normal highlight
  set statusline+=\ %3*                         " switch to User3 highlight
  set statusline+=%{statusline#git_status()}
  set statusline+=%*                            " normal highlight
  set statusline+=\ %5*                         " switch to User5 highlight
  set statusline+=%{statusline#virtualenv_status()}
  set statusline+=%*\                           " normal highlight

  set statusline+=%=                            " right align
  set statusline+=%4*                           " switch to User4 highlight
  set statusline+=%{statusline#syntastic_status()}
  set statusline+=%*\                           " normal highlight
  set statusline+=%{&spell?'SP\ ':''}
  set statusline+=%4*%{&paste?'PASTE\ ':''}%*   " paste mode flag
  set statusline+=%h                            " help buffer flag
  set statusline+=%r                            " read only flag
  set statusline+=%m                            " modified flag
  set statusline+=%l/%L                         " line number / total lines
  set statusline+=:%c                           " column
endfunction

" set the statusline highlighting for insert mode
function! statusline#set_insert_statusline()
  hi statusline ctermbg=20 ctermfg=19
  hi User1 ctermbg=20 ctermfg=0  "buffer number
  hi User2 ctermbg=20 ctermfg=1  "filetype
  hi User3 ctermbg=20 ctermfg=4  "fugitive(git)
  hi User4 ctermbg=1  ctermfg=7  "syntastic
  hi User5 ctermbg=20 ctermfg=2  "virtualenv
endfunction

" set the statusline highlighting for normal mode
function! statusline#clear_insert_statusline()
  hi statusline ctermbg=19 ctermfg=20
  hi User1 ctermbg=19 ctermfg=0  "buffer number
  hi User2 ctermbg=19 ctermfg=1  "filetype
  hi User3 ctermbg=19 ctermfg=4  "fugitive(git)
  hi User4 ctermbg=1  ctermfg=7  "syntastic
  hi User5 ctermbg=19 ctermfg=2  "virtualenv
endfunction

function! statusline#virtualenv_status()
  if exists('g:virtualenv_loaded')
    let venv_stat = virtualenv#statusline()
    if (venv_stat != '')
      return '[venv:'.venv_stat.']'
    endif
  endif
  return ''
endfunction

function! statusline#git_status()
  if exists('g:loaded_fugitive')
    let git_stat = fugitive#head()
    if (git_stat != '')
      return '[⎇  '.git_stat.']'
    endif
  endif
  return ''
endfunction

function! statusline#syntastic_status()
  if exists('g:loaded_syntastic_plugin')
    return SyntasticStatuslineFlag()
  endif
  return ''
endfunction
