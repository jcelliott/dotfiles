"          _              
"    _  __(_)_ _  ________
"  _| |/ / /  ' \/ __/ __/
" (_)___/_/_/_/_/_/  \__/ 
"                        
" Joshua Elliott
" Created 6/28/12
"
" TODO: "{{{
"	  - Command to toggle autocompletion (tab, delimeters, etc.)
"	  - marks and highlights system (like current <leader>l) with <leader>1-9
"   - LaTeX support
"}}}

"------------------------------------------------------------------------------
" General Settings
"------------------------------------------------------------------------------
"{{{

set nocompatible        " vim settings instead of vi settings

set bs=indent,eol,start " allow backspacing over everything in insert mode
set history=100         " keep x lines of command line history
set ruler               " show the cursor position all the time
set number              " Show line numbers
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set hlsearch            " highlight search
set ignorecase          " case insensitive search
set smartcase           " case sensitive search if using uppercase chars
set mouse=a             " enable mouse
set scrolloff=5         " Always leave visible lines at top and bottom of window
set scrolljump=5        " Lines to scroll when cursor leaves screen
set foldenable          " enable folds, toggle with zi
set nostartofline       " don't move to SOL on many commands (also switching buffers)
set autoread            " auto read on external file changes
set hidden              " allow buffers to remain open in the background

set formatoptions=cqnl  " settings for formatting (see :help fo-table)
set textwidth=100       " wrap lines at 100 chars
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
set expandtab           " expand tabs to spaces
set autoindent

set pastetoggle=<F2>    " toggle paste mode (while paste is enabled, all formatting is disabled)
                        " OR :set invpaste<CR>:set paste?<CR>

if $TMUX == ''
  if(system("uname") =~ "Darwin")
    set clipboard=unnamed     " Use the system clipboard (* register) on mac
  else
    set clipboard=unnamedplus " Use the X window clipboard (+ register)
  endif
endif

" get rid of 'X more files to edit' message on quit
" autocmd VimEnter * last|rewind

" remove the delay when exiting insert mode (purely cosmetic, updates the statusline color immediately)
" doesn't wait to receive key codes, doesn't affect multi-character mappings (imap jk <esc> won't work)
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

" Tell vim to remember certain things when we exit
"  '25  :  marks will be remembered for up to 25 previously edited files
"  "1000:  will save up to 1000 lines for each register
"  :50  :  up to 50 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='25,\"10000,:50,%,n$HOME/.vim/.viminfo

" Load plugins
runtime bundle/pathogen/autoload/pathogen.vim
if exists('g:loaded_pathogen')
  call pathogen#infect()
  " call LoadPluginMaps()
endif
" silent! call pathogen#infect()

" Enable syntax highlighting and keep current colors
syntax enable

" automatically source vimrc when written
autocmd! BufWritePost .vimrc,_vimrc,vimrc source $MYVIMRC

" When editing a file, always jump to the last known cursor position. Don't do it when the 
" position is invalid or when inside an event handler (happens when dropping a file on gvim). Also 
" don't do it when the mark is in the first line, that is the default position when opening a file.
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" automatically save folds and attempt to load them when opening a file
autocmd BufWinLeave ?* mkview
autocmd BufWinEnter ?* silent loadview

autocmd BufLeave * let b:winview = winsaveview()
autocmd BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif

" Really set formatoptions. Filetype-specific plugins will override the default setting.
" This autocommand will execute after any filetype plugins.
" autocmd FileType * setlocal formatoptions=cqnl
"}}}

"------------------------------------------------------------------------------
" Functions and Commands
"------------------------------------------------------------------------------
"{{{

" Convenient command to see the difference between the current buffer and the file it was loaded 
" from, thus the changes you made. Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" run the current script with <F5>
function! RunScript()
  if exists("b:interpreter")
    exec("!".b:interpreter." %")
  else
    echo "No interpreter defined for " . &filetype
  endif
endfunction

" run REPL for current filetype (if applicable) with <F4>
function! REPL()
  if exists("b:repl")
    exec("!".b:repl)
  else
    echo "No REPL defined for " . &filetype
  endif
endfunction

" copy the output of an ex command to a new tab
function! TabMessage(cmd)
  redir => message
  silent execute a:cmd
  redir END
  tabnew
  silent put=message
  set nomodified
endfunction
command! -nargs=+ -complete=command TabMessage call TabMessage(<q-args>)

"}}}

"------------------------------------------------------------------------------
" Mappings
"------------------------------------------------------------------------------
"{{{
" ----- Basic ----- "{{{
" Use ; like : for commands (easier to type, prevents accidental capitalization errors)
nnoremap ; :

" Use , for leader (easier to type, standard location)
let mapleader = ','

" Yank from cursor to eol (like D, C)
nnoremap Y y$

" yank entire file
nnoremap <leader>y ggyG`` :echo "yanked entire file"<CR>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
"}}}

" ----- Movement and Selection ----- "{{{
" Move lines and blocks up and down
map <C-Down> ddp
map <C-Up> ddkP
vmap <C-Down> dpV`]
vmap <C-Up> dkPV`]

" Insert lines above or below
noremap go o<esc>k
noremap gi O<esc>j

" up and down hold cursor while lines scroll
noremap <Down> <C-e>j
noremap <Up> <C-y>k

" H and L go to beginning and end of visual line
" noremap H ^
" noremap L $
noremap H g^
noremap L g$

" j and k move visual lines instead of real lines
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" J and K move more lines at a time
nmap J 5j
nmap K 5k
xmap J 5j
xmap K 5k

" Replace J(oin) with \j (because of above mapping)
nmap \j :join<CR>

" Visual shifting (without exiting Visual mode)
vnoremap < <gv
vnoremap > >gv

" Move between splits with ctrl + hjkl
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

" Easier movement in insert mode
imap <C-h> <home>
imap <C-j> <down>
imap <C-k> <up>
imap <C-l> <end>

" select last modified text
nmap <leader>x `[v`]
"}}}

" ----- Marks and Highlighting ----- "{{{
" <leader>l will highlight the current line and set mark l.
" Use 'l to return and :match to clear
nnoremap <silent> <leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>

" <Space> turn off highlighting, clear search pattern, clear messages
nnoremap <silent> <Space> :let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>

" <leader><Space> Really clear:
" turn off highlighting, clear search pattern, clear messages, clear match highlight, 
" clear quickfix list, clear location list :cgetexpr [] :lgetexpr []
nnoremap <silent> <leader><Space> :let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>:match<CR>:cgetexpr[]<CR>:lgetexpr[]<CR>

" <leader>/ highlights occurrences of the word under cursor. Like * but doesn't move
map <silent> <leader>/ :let @/ = '\<'.expand('<cword>').'\>'\|set hlsearch<C-M>

"}}}

" ----- Commands ----- "{{{
" Edit and reload vimrc
nmap <silent> <leader>v :e $MYVIMRC<CR>
nmap <silent> \s :source $MYVIMRC<CR>:echo "sourced vimrc"<CR>

" Dirty hack for when you forget to sudo. Really write the File 
cmap w!! w !sudo tee % >/dev/null

" run make
map <F6> :w<CR>:make<CR>

" run the current script with <F5>
map <F5> :w<CR> :call RunScript()<CR>

" run REPL for current filetype (if applicable) with <F4>
map <F4> :call REPL()<CR>

" add the name of the current file in a comment at the top of the file
" (depends on tcomment [mapped to gcc to comment the current line])
map <F3> mnggO<C-R>%<ESC>gcc'n

" copy the output of an ex command to a new tab
map \t :TabMessage 

" go to shell (exit the shell to return to vim)
map gs :sh<CR>

" TODO lists. Changes the first occurence of - to ✓ and vice-versa
" map <silent> \c :.s/-/✓/e<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
" map <silent> \x :.s/✓/-/e<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
" Changes [ ] to [x] and vice-versa. '/e' flag ignores errors
map <silent> \c :.s/^\[x\]/\[ \]/e<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
map <silent> \x :.s/^\[ \]/\[x\]/e<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
" add and remove check boxes ([ ]) at the beginning of the line
map <silent> \z ^i[ ] <esc>$
map <silent> \v :.s/^\[[x ]\][ ]\?//e<CR>:let @/ = ""<CR>:nohlsearch<Bar>:echo<CR>
"}}}

" ----- Files and Navigation ----- "{{{
" Vim built-in explorer (Split Explore)
map <leader>e :Sexplore<CR>

" close current buffer
map <silent> <leader>q :bd<CR> 
"}}}

" use <leader>c for comments (gcc from tComment)
nmap <leader>c gcc
vmap <leader>c gc

" redraw screen
map \l :redraw!<CR>

" diff mode maps (vimdiff)
if &diff | map <silent> <leader>du :diffupdate<CR>| endif
if &diff | map <leader>dp :diffput BASE<CR>| endif

" toggle spell check
nmap <silent> <F7> :setlocal spell! spelllang=en_us<CR>
imap <silent> <F7> <C-o>:setlocal spell! spelllang=en_us<CR>
"}}}

"------------------------------------------------------------------------------
" Neobundle and Plugins
"------------------------------------------------------------------------------
"{{{

" if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle
" endif
call neobundle#rc(expand('~/.vim/bundle'))

" Let neobundle manage neobundle
NeoBundleFetch 'Shougo/neobundle.vim'

" Plugins
NeoBundle 'scrooloose/syntastic' "{{{
  " Move to the next and previous location in the location list
  " (used to move between syntastic error locations)
  " map <silent> <leader>g :lfirst<CR>
  map <silent> <leader>j :lnext<CR>
  map <silent> <leader>k :lprev<CR>

  if exists("g:loaded_syntastic_plugin")
    " show error markers in gutter
    let g:syntastic_enable_signs=1
    " Syntastic error list will appear when errors are detected
    let g:syntastic_auto_loc_list=1
    " Syntastic error list hight
    let g:syntastic_loc_list_height=5
    " Toggle Syntastic mode [active|passive]
    map <leader>z :SyntasticToggleMode<CR>
    " Manually start a syntax check (syntastic)
    map <leader>a :SyntasticCheck<CR>
  endif
"}}}
NeoBundle 'sjbach/lusty' "{{{
  " if exists("g:loaded_lustyexplorer")
    let g:LustyExplorerSuppressRubyWarning = 1
    map <silent> <leader>, :LustyJuggler<CR>
    map <silent> <leader>. :LustyJugglePrevious<CR>
    map <silent> <leader>f :LustyFilesystemExplorerFromHere<CR>
    map <silent> <leader>h :LustyFilesystemExplorer $HOME<CR>
    " map <silent> <leader>b :LustyBufferExplorer<CR> " use <leader>lb
  " endif
"}}}
NeoBundle 'scrooloose/nerdtree' "{{{
  if exists("g:loaded_nerd_tree")
    map <silent> <leader>tt :NERDTreeToggle<CR>
    map <silent> <leader>th :NERDTree $HOME<CR>
  endif
"}}}
NeoBundle 'tpope/vim-eunuch' "{{{
  if exists("g:loaded_eunuch")
    " Rename (there is a literal space after :Move)
    map <leader>r :Move 
    " Remove (no confirmation)
    map <leader>ddd :Remove<CR>
    " Write a privileged file with sudo
    map <leader>w :SudoWrite<CR>
  endif
"}}}
NeoBundle 'greyblake/vim-preview' "{{{
  " vim-preview (markdown, rdoc, textile, html, ronn, rst)
  if exists(":Preview")
    " if(!exists('g:PreviewBrowsers'))
      if(system("uname") =~ "Darwin")
        let g:PreviewBrowsers = 'open,google-chrome,safari,firefox'
      else
        let g:PreviewBrowsers = 'chromium,firefox,epiphany'
      endif
    " endif
    " remove default mapping and add custom one
    autocmd VimEnter * 
      \ nunmap <leader>P
      \ nmap <silent> <leader>p :Preview<CR>
  endif
"}}}
NeoBundle 'tpope/vim-surround' "{{{
  if exists("g:loaded_surround")
    map <leader>s ysiw
  endif
"}}}
NeoBundle 'majutsushi/tagbar' "{{{
  " if exists("g:loaded_tagbar")
    let g:tagbar_autofocus=1
    let g:tagbar_sort=0
    let g:tagbar_autoshowtag=1
    nmap <silent> <leader>b :TagbarOpenAutoClose<CR>
  " endif
"}}}
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'ervandew/supertab'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'nelstrom/vim-textobj-rubyblock', {'depends': 'kana/vim-textobj-user'}
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'jnwhiteh/vim-golang'
NeoBundle 'peterhoeg/vim-tmux'
" NeoBundle 'digitaltoad/vim-jade'
  " autocmd FileType jade NeoBundleSource 'vim-jade'

if !has('vim_starting')
  " Call on_source hook when reloading .vimrc.
  call neobundle#call_hook('on_source')
endif

" Enable file type detection.
" Also load indent files, to automatically do language-dependent indenting.
" neobundle requires the filetypes to be loaded after all bundles are loaded
filetype plugin indent on

" Installation check.
NeoBundleCheck

"}}}

"------------------------------------------------------------------------------
" Appearance
"------------------------------------------------------------------------------
"{{{

set background=dark
set t_Co=16
let g:solarized_termcolors=16
colorscheme solarized

" Line number highlight
hi LineNr ctermfg=239 ctermbg=darkgray guifg=darkslategray
" hi LineNr ctermfg=darkgray

" Highlight for current line
set cursorline
hi cursorline ctermbg=black gui=bold

" always show the status line
set laststatus=2

" Highlights for status line (must appear after any :colorscheme)
hi User1 ctermbg=black ctermfg=darkgreen guibg=steelblue4 guifg=darkgray "buffer number
hi User2 ctermbg=black ctermfg=darkred   guibg=black      guifg=darkred  "filetype
hi User3 ctermbg=black ctermfg=darkblue  guibg=gray	      guifg=darkblue "fugitive(git)
hi User4 ctermbg=red	 ctermfg=white     guibg=red        guifg=white    "syntastic

" Set the default statusline highlight
hi statusline ctermbg=gray ctermfg=black guibg=gray guifg=steelblue4

" Sets the status line highlighting according the current mode
function! SetInsertStatusline()
hi statusline ctermbg=gray  ctermfg=red      guibg=gray  guifg=orangered4
hi User2      ctermbg=red ctermfg=darkred  guibg=white guifg=darkred    "filetype
hi User3      ctermbg=red ctermfg=darkblue guibg=white	guifg=darkblue  "fugitive(git)
endfunction
au InsertEnter * :call SetInsertStatusline()

function! ClearInsertStatusline()
hi statusline ctermbg=gray  ctermfg=black    guibg=gray  guifg=steelblue4
hi User2      ctermbg=black ctermfg=darkred  guibg=black guifg=darkred    "filetype
hi User3      ctermbg=black ctermfg=darkblue guibg=gray	 guifg=darkblue   "fugitive(git)
endfunction
au InsertLeave * :call ClearInsertStatusline()

" Statusline formatting	                      (Remember to escape spaces '\ ')
set statusline=
set statusline+=%1*[%n]%*	                    " buffer number
set statusline+=\ %F                          " full filename
set statusline+=\ %2*                         " switch to User2 highlight
set statusline+=%y                            " filetype
set statusline+=%*                            " normal highlight
set statusline+=\ %3*                         " switch to User3 highlight
"git status (if the plugin is loaded)
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}
set statusline+=%*                            " normal highlight

set statusline+=%=                            " right align
set statusline+=%4*                           " switch to User4 highlight
set statusline+=%{SyntasticStatuslineFlag()}  " syntastic warnings
set statusline+=%*\                           " normal highlight
set statusline+=%{&spell?'SP\ ':''}
set statusline+=%4*%{&paste?'PASTE\ ':''}%*   " paste mode flag
set statusline+=%h                            " help buffer flag
set statusline+=%r                            " read only flag
set statusline+=%m                            " modified flag
set statusline+=%l/%L                       " line number / total lines
set statusline+=:%c                           " column
"}}}

"------------------------------------------------------------------------------
" Language specific options
"------------------------------------------------------------------------------
"{{{

" These should be set in ~/.vim/after/ftplugin/<plugin>.vim
"}}}

"------------------------------------------------------------------------------
" HACKS
"------------------------------------------------------------------------------
"{{{

" make keypad work in vim with iTerm on OS X
function! MacKeypadFix()
  map <Esc>Oq 1
  map <Esc>Or 2
  map <Esc>Os 3
  map <Esc>Ot 4
  map <Esc>Ou 5
  map <Esc>Ov 6
  map <Esc>Ow 7
  map <Esc>Ox 8
  map <Esc>Oy 9
  map <Esc>Op 0
  map <Esc>On .
  map <Esc>OQ /
  map <Esc>OR *
  map <kPlus> +
  map <Esc>OS -
  map! <Esc>Oq 1
  map! <Esc>Or 2
  map! <Esc>Os 3
  map! <Esc>Ot 4
  map! <Esc>Ou 5
  map! <Esc>Ov 6
  map! <Esc>Ow 7
  map! <Esc>Ox 8
  map! <Esc>Oy 9
  map! <Esc>Op 0
  map! <Esc>On .
  map! <Esc>OQ /
  map! <Esc>OR *
  map! <kPlus> +
  map! <Esc>OS -
endfunction

if has("unix")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    call MacKeypadFix()
  endif
endif
"}}}

" -----------------------------------------------------------------------------
" UNSORTED / EXPERIMENTAL
" -----------------------------------------------------------------------------
"{{{

" temporary map in order to use instant-markdown
" in a separate terminal run `instant-markdown-d`
" autocmd BufWritePost *.md,*.markdown :silent !cat %:p | curl -X PUT -T - http://localhost:8090/

" experimenting with ESC
" imap jk <ESC>
" imap kj <ESC>
"}}}
