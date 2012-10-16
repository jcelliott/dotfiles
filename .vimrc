"          _              
"    _  __(_)_ _  ________
"  _| |/ / /  ' \/ __/ __/
" (_)___/_/_/_/_/_/  \__/ 
"                        
" Joshua Elliott
" Created 6/28/12
"
" TODO:
"	  - Command to toggle autocompletion (tab, delimeters, etc.)
"	  - marks and highlights system (like current <leader>l) with <leader>1-9
"	  - change highlight colors in status bar on transition to insert mode
"	  - organize this mess!

"----------------------------------------------------------
" General Settings
"----------------------------------------------------------

" vim settings instead of vi settings
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=100		  " keep x lines of command line history
set ruler		        " show the cursor position all the time
set showcmd		      " display incomplete commands
set incsearch		    " do incremental searching
set hlsearch        " highlight search
set smartcase       " case sensitive search if using uppercase chars
set mouse=a         " enable mouse
"set background=dark " assume we're using a dark background
set tabstop=2
set shiftwidth=2
set smarttab
set expandtab
set softtabstop=2
set autoindent
set autoread        " auto read on external file changes
set hidden
"syntax on

" Tell vim to remember certain things when we exit
"  '25  :  marks will be remembered for up to 25 previously edited files
"  "1000:  will save up to 1000 lines for each register
"  :50  :  up to 50 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='25,\"250,:50,%,n~/.viminfo

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Language specific options

  " go
  set rtp+=$GOROOT/misc/vim
  autocmd BufWritePre *.go :silent Fmt


  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif


"----------------------------------------------------------
"if exists('g:loaded_pathogen')
  call pathogen#infect()
"endif
filetype plugin indent on

" Open NertTree when Vim Starts
"au VimEnter * NERDTree
"au VimEnter * wincmd p

" .json files are javascript
" au BufRead,BufNewFile *.json set ft=javascript

syntax enable
set background=dark
colorscheme solarized

"map <C-s> set paste

function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

"----------------------------------------------------------

" automatically source vimrc when written
au! BufWritePost .vimrc,_vimrc,vimrc source $MYVIMRC

" Use ; like : for commands (easier to type, prevents accidental
" capitalization errors)
nnoremap ; :

" Use , for leader (easier to type, standard location)
let mapleader = ','

" Yank from cursor to eol (like D, C)
nnoremap Y y$

" For when you forget to sudo. Really write the File 
" (from:Steve Fancia [spf13.com])
cmap w!! w !sudo tee % >/dev/null

" <leader>l will highlight the current line and set mark l.
" Use 'l to return and :match to clear
:nnoremap <silent> <leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>

" <Space> turn off highlighting, clear search pattern, clear messages
nnoremap <silent> <Space> :let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
" <leader><Space> to do the above and clear match highlight
nnoremap <silent> <leader><Space> :let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>:match<CR>

" <leader>/ highlights occurrences of the word under cursor
map <silent> <leader>/ :let @/ = '\<'.expand('<cword>').'\>'\|set hlsearch<C-M>

" Use the system clipboard for cut and copy (not working right now on osx)
set clipboard=unnamed

" ctrl-j and ctrl-k to hold cursor while lines scroll
map <C-j> <C-e>j
map <C-k> <C-y>k

" H and L go to beginning and end of line
noremap H ^
noremap L $

" Move to first, next, and previous location in the location list
" (used to move between syntastic error locations)
map <silent> <leader>g :lfirst<CR>
map <silent> <leader>j :lnext<CR>
map <silent> <leader>k :lprev<CR>

" Visual shifting (without exiting Visual mode) [should be able to the same
" thing with > and then . to repeat]
vnoremap < <gv
vnoremap > >gv

" Always leave visible lines at top and bottom of window
set scrolloff=8
" Lines to scroll when cursor leaves screen
set scrolljump=5

" toggle paste mode
set pastetoggle=<F2>

" Auto fold code
set foldenable

" Show line numbers
set number
"set numberwidth=5

" Line number highlight
hi LineNr ctermfg=DarkGray

" Highlight for current line
hi cursorline cterm=bold gui=bold
"hi cursorline cterm=NONE ctermbg=Black
set cursorline

" Edit and reload vimrc
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" LustyJuggler / LustyExplorer mappings
let g:LustyExplorerSuppressRubyWarning = 1
map <silent> <leader>, :LustyJuggler<CR>
map <silent> <leader>. :LustyJugglePrevious<CR>
map <silent> <leader>f :LustyFilesystemExplorerFromHere<CR>
map <silent> <leader>h :LustyFilesystemExplorer $HOME<CR>
map <silent> <leader>b :LustyBufferExplorer<CR>
map <silent> <leader>q :bd<CR> " closes current buffer

" always show the status line
set laststatus=2

" Sets the status line highlighting according the current mode
au InsertEnter * hi statusline ctermbg=White ctermfg=Red       guibg=White guifg=Red
au InsertLeave * hi statusline ctermbg=White ctermfg=DarkGray  guibg=White guifg=DarkGray

" Set the default statusline highlight
hi statusline ctermbg=White ctermfg=DarkGray guibg=White guifg=DarkGray

" Highlights for status line (must appear after any :colorscheme)
hi User1 ctermbg=darkgray	ctermfg=lightblue	guibg=darkgray guifg=lightblue
hi User2 ctermbg=gray   ctermfg=darkred     guibg=gray	guifg=darkred
hi User3 ctermbg=gray   ctermfg=darkmagenta guibg=gray	guifg=darkmagenta
hi User4 ctermbg=red	  ctermfg=white       guibg=red   guifg=white

" Statusline formatting	                      (Remember to escape spaces '\ ')
set statusline=
set statusline+=%1*[%n]%*	                    "buffer number
set statusline+=\ %F                          "full filename
set statusline+=\ %2*                         "switch to User2 highlight
set statusline+=%y                            "filetype
set statusline+=%*                            "normal highlight
set statusline+=\ %3*                         "switch to User3 highlight
"git status (if the plugin is loaded)
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}
set statusline+=%*                            "normal highlight

set statusline+=%=                            "right align
set statusline+=%4*                           "switch to User4 highlight
"syntastic warnings (if the plugin is loaded)
set statusline+=%{exists('g:loaded_syntastic')?SyntasticStatuslineFlag():''}
set statusline+=%*                            "normal highlight
set statusline+=\ %r                          "read only flag
set statusline+=%m                            "modified flag
set statusline+=\ %l/%L                       "line number / total lines
set statusline+=:%c                           "column

