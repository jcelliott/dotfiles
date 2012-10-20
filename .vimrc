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

"------------------------------------------------------------------------------
" General Settings
"------------------------------------------------------------------------------

set nocompatible        " vim settings instead of vi settings

set bs=indent,eol,start " allow backspacing over everything in insert mode
set history=100         " keep x lines of command line history
set ruler               " show the cursor position all the time
set number              " Show line numbers
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set hlsearch            " highlight search
set smartcase           " case sensitive search if using uppercase chars
set mouse=a             " enable mouse
set scrolloff=5         " Always leave visible lines at top and bottom of window
set scrolljump=5        " Lines to scroll when cursor leaves screen
set foldenable          " Auto fold code

set formatoptions=cqnlj " settings for formatting (see :help fo-table)
                        " (also see autocmd for formatoptions below)
set textwidth=120       " wrap lines at 120 chars
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
set expandtab           " expand tabs to spaces
set autoindent

set autoread            " auto read on external file changes
set hidden              " allow buffers to remain open in the background
set clipboard=unnamed   " Use the system clipboard for cut and copy
set pastetoggle=<F2>    " toggle paste mode

" Tell vim to remember certain things when we exit
"  '25  :  marks will be remembered for up to 25 previously edited files
"  "1000:  will save up to 1000 lines for each register
"  :50  :  up to 50 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='25,\"1000,:50,%,n$HOME/.vim/.viminfo

" Load plugins
" if exists('g:loaded_pathogen') " this was causing problems
  call pathogen#infect()
" endif

" Enable file type detection.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

" Enable syntax highlighting and keep current colors
syntax enable

" automatically source vimrc when written
autocmd! BufWritePost .vimrc,_vimrc,vimrc source $MYVIMRC

" Really set formatoptions. Filetype-specific plugins will override the default setting.
" This autocommand will execute after any filetype plugins.
autocmd FileType * setlocal formatoptions=cqnlj


"------------------------------------------------------------------------------
" Appearance
"------------------------------------------------------------------------------

set background=dark
colorscheme solarized

" Line number highlight
hi LineNr ctermfg=DarkGray

" Highlight for current line
hi cursorline cterm=bold gui=bold
"hi cursorline cterm=NONE ctermbg=Black
set cursorline

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


"------------------------------------------------------------------------------
" Mappings
"------------------------------------------------------------------------------

" Use ; like : for commands (easier to type, prevents accidental capitalization errors)
nnoremap ; :

" Use , for leader (easier to type, standard location)
let mapleader = ','

" Edit and reload vimrc
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

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

" <leader><Space> Really clear:
" turn off highlighting, clear search pattern, clear messages, clear match highlight, 
" clear quickfix list, clear location list :cgetexpr [] :lgetexpr []
nnoremap <silent> <leader><Space> :let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>:match<CR>:cgetexpr[]<CR>:lgetexpr[]<CR>

" <leader>/ highlights occurrences of the word under cursor
map <silent> <leader>/ :let @/ = '\<'.expand('<cword>').'\>'\|set hlsearch<C-M>

" TODO lists. Changes the first occurence of - to ✓ and vice-versa
map <silent> <leader>c :.s/-/✓<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
map <silent> <leader>x :.s/✓/-<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>

" Move lines up and down
map <C-j> ddp
map <C-k> ddkP

" Insert lines above or below
noremap go o<esc>k
noremap gi O<esc>j

" up and down hold cursor while lines scroll
noremap <Down> <C-e>j
noremap <Up> <C-y>k

" H and L go to beginning and end of line
noremap H ^
noremap L $

" Visual shifting (without exiting Visual mode) [should be able to the same
" thing with > and then . to repeat]
vnoremap < <gv
vnoremap > >gv


"------------------------------------------------------------------------------
" Plugin Mappings
"------------------------------------------------------------------------------

" Move to first, next, and previous location in the location list
" (used to move between syntastic error locations)
map <silent> <leader>g :lfirst<CR>
map <silent> <leader>j :lnext<CR>
map <silent> <leader>k :lprev<CR>

" LustyJuggler / LustyExplorer mappings
let g:LustyExplorerSuppressRubyWarning = 1
map <silent> <leader>, :LustyJuggler<CR>
map <silent> <leader>. :LustyJugglePrevious<CR>
map <silent> <leader>f :LustyFilesystemExplorerFromHere<CR>
map <silent> <leader>h :LustyFilesystemExplorer $HOME<CR>
map <silent> <leader>b :LustyBufferExplorer<CR>
map <silent> <leader>q :bd<CR> " closes current buffer


"------------------------------------------------------------------------------
" Language specific options
"------------------------------------------------------------------------------

" ----- go -----

set rtp+=$GOROOT/misc/vim
autocmd BufWritePre *.go :silent Fmt



" ----------- UNSORTED -----------

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

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
