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
"   - Organize into separate files?
"}}}

"------------------------------------------------------------------------------
" General Settings
"------------------------------------------------------------------------------
"{{{

set nocompatible        " vim settings instead of vi settings

" have vim use a more POSIX compatible shell than fish
if &shell =~# 'fish$'
  set shell=bash
endif

set autochdir           " automatically chdir into directory of current file
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
" set scrolljump=5        " Lines to scroll when cursor leaves screen
set foldenable          " enable folds, toggle with zi
set nostartofline       " don't move to SOL on many commands (also switching buffers)
set autoread            " auto read on external file changes
set hidden              " allow buffers to remain open in the background
set undofile            " undo tree persists between vim sessions
set updatetime=1000     " timeout for CursorHold autocmd and writing swap file
set confirm             " confirm dialog instead of fail
set wildmenu						" autocomplete menu for command line
set wildmode=longest,list,full
set undodir=$HOME/.vim/undohist
set completeopt=menu,longest,preview
set wildignore=*.swp,*.pyc

set ruler               " show the cursor position all the time
set number              " Show line numbers
set showcmd             " display incomplete commands
set pumheight=30        " popup completion menu max height
set splitright          " vertical splits go to the right
set splitbelow          " horizontal splits to below

set formatoptions=cqnlj " settings for formatting (see :help fo-table)
set textwidth=100       " wrap lines at 100 chars
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
" set nosmarttab
set expandtab           " expand tabs to spaces
" set noexpandtab         " don't expand tabs to spaces
set autoindent

set pastetoggle=<F2>    " toggle paste mode (while paste is enabled, all formatting is disabled)
                        " OR :set invpaste<CR>:set paste?<CR>
set ttyfast             " improves redrawing for fast terminal connection

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
        au InsertEnter * set timeoutlen=100
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

" Tell vim to remember certain things when we exit
"  '25  :  marks will be remembered for up to 25 previously edited files
"  "1000:  will save up to 1000 lines for each register
"  :100  :  up to 50 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='25,\"10000,:100,%,n$HOME/.vim/.viminfo

" Load plugins
" runtime bundle/pathogen/autoload/pathogen.vim
" if exists('g:loaded_pathogen')
"   call pathogen#infect()
"   " call LoadPluginMaps()
" endif
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
" autocmd BufWinLeave ?* mkview
" autocmd BufWinEnter ?* silent loadview

" automatically close location list window when leaving a buffer
" prevents the annoying case where the location list stays open after closing
" its associated file buffer
" TODO: bug - this closes the location list window when you try to switch to it
" autocmd BufLeave * lclose

" attempt to return to the same view when switching buffers
" causing problems, look into it later
" autocmd BufLeave * let b:winview = winsaveview()
" autocmd BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
"}}}

"------------------------------------------------------------------------------
" Functions and Commands
"------------------------------------------------------------------------------
"{{{

" See the difference between the current buffer and the file it was loaded 
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

" switch between number and relativenumber
function! NumberToggle()
  if(&relativenumber == 1)
    set nornu
  else
    set relativenumber
  endif
endfunc

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
"}}}

" ----- Editing ----- "{{{

" Yank from cursor to eol (like D, C)
nnoremap Y y$

" allow repeat operator with a visual selection
vnoremap . :normal .<cr>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" use <M-k> for digraphs instead of <C-k>
inoremap ˚ <C-k>

"}}}

" ----- Movement and Selection ----- "{{{
" Move lines and blocks up and down
" map <C-Down> ddp
" map <C-Up> ddkP
map <C-Down> :m .+1<CR>==
map <C-Up> :m .-2<CR>==
" vmap <C-Down> dpV`]
" vmap <C-Up> dkPV`]
vmap <C-Down> :m '>+1<CR>gv=gv
vmap <C-Up> :m '<-2<CR>gv=gv

" Insert lines above or below
noremap go o<esc>k
noremap gi O<esc>j

" up and down hold cursor while lines scroll
noremap <Down> <C-e>j
noremap <Up> <C-y>k
" mouse scroll wheel does the same
map <ScrollWheelDown> 5<C-e>5j
map <ScrollWheelUp> 5<C-y>5k

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

" <C-j> and <C-k> move 5 lines at a time
" nmap <C-j> 5j
" nmap <C-k> 5k
" xmap <C-j> 5j
" xmap <C-k> 5k

" Replace J(oin) with \j (because of above mapping)
" not needed after changing to <C-j>
" nmap \j :join<CR>

" Visual shifting (without exiting Visual mode)
vnoremap < <gv
vnoremap > >gv

" " Move between splits with ctrl + hjkl
" used for fast scroll now, were used infrequently
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

" Easier movement in insert mode
" Don't spend time in insert mode!
" inoremap <C-h> <home>
" inoremap <C-j> <down>
" inoremap <C-k> <up>
" inoremap <C-l> <end>

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

" What is the current syntax highlighting group?
map \h :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">" . " FG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#") . " BG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"bg#")<CR>

" Toggle show whitespace
map \w :<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list? <CR>
"}}}

" ----- Commands ----- "{{{
" Save from insert mode
imap ;w <C-o>:w<CR>
imap ;w<CR> <C-o>:w<CR>

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
" map \t :TabMessage 

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

" yank entire file
nnoremap <leader>y ggyG`` :echo "yanked entire file"<CR>

" Vim built-in explorer (Split Explore)
map <leader>- :Sexplore<CR>

" close current buffer
map <silent> <leader>q :bd<CR> 
"}}}

" toggle between number and relativenumber
nnoremap <leader>n :call NumberToggle()<CR>

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
" Plugins
"------------------------------------------------------------------------------
"{{{

call plug#begin('~/.vim/bundle')

" Plugins
Plug 'scrooloose/syntastic', { 'on': 'SyntasticToggleMode' } "{{{
  " show error markers in gutter
  let g:syntastic_enable_signs=1
  " Syntastic error list will appear when errors are detected
  let g:syntastic_auto_loc_list=1
  " Syntastic error list hight
  let g:syntastic_loc_list_height=5
	" Always add errors (:Errors) to location list
	let g:syntastic_always_populate_loc_list=1
	" Run all checkers in parallel instead of stopping after the first
	let g:syntastic_aggregate_errors = 1
	" Symbols to display in the gutter
	let g:syntastic_error_symbol = '✗'
	let g:syntastic_warning_symbol = '⚠'
  let g:syntastic_style_warning_symbol = 's'
  let g:syntastic_style_error_symbol = 'S'
	" Customize syntastic status line message
	let g:syntastic_stl_format = '[%E{Err: %e}%B{, }%W{Warn: %w}]'
  " default to passive, so when we toggle (for lazy load) it starts in active mode
  let g:syntastic_mode_map = { 'mode': 'passive' }

  " Move to the next and previous location in the location list
  " (used to move between syntastic error locations)
  " map <silent> <leader>g :lfirst<CR>
  map <silent> <leader>j :lnext<CR>
  map <silent> <leader>k :lprev<CR>
  " Toggle Syntastic mode [active|passive]
  map <leader>z :SyntasticToggleMode<CR>
  " Manually start a syntax check (syntastic)
  " map <leader>a :SyntasticCheck<CR>
  map <silent> <leader>a :SyntasticReset<CR>
"}}}
Plug 'sjbach/lusty' "{{{
  let g:LustyExplorerSuppressRubyWarning = 1
  let g:LustyExplorerDefaultMappings = 0
  let g:LustyJugglerDefaultMappings = 0
  map <silent> <leader>, :LustyJuggler<CR>
  map <silent> <leader>. :LustyJugglePrevious<CR>
  map <silent> <leader>f :LustyFilesystemExplorerFromHere<CR>
  map <silent> <leader>h :LustyFilesystemExplorer $HOME<CR>
  map <silent> <leader>g :LustyBufferGrep<CR>
  map <silent> <leader>b :LustyBufferExplorer<CR>
  " map <silent> <leader>b :LustyBufferExplorer<CR> " use <leader>lb
"}}}
Plug 'tpope/vim-eunuch' "{{{
  " Rename (there is a literal space after :Move)
  map <leader>r :Rename 
  " Remove (no confirmation)
  map \ddd :Remove<CR>
  " Write a privileged file with sudo
  map <leader>w :SudoWrite<CR>
"}}}
Plug 'tpope/vim-surround' "{{{
  map <leader>s ysiw
"}}}
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-dispatch', { 'on': 'Dispatch' } "{{{
  map <leader>d :Dispatch<CR>
"}}}
Plug 'tpope/vim-abolish'
Plug 'majutsushi/tagbar', { 'on': ['TagbarOpenAutoClose'] } "{{{
  let g:tagbar_autofocus = 1
  let g:tagbar_sort = 0
  let g:tagbar_autoshowtag = 1
  nmap <silent> <leader>y :TagbarOpenAutoClose<CR>
"}}}
Plug 'tomtom/tcomment_vim' "{{{
  " use <leader>c for comments (gcc from tComment)
  nmap <leader>c gcc
  vmap <leader>c gc
  let g:tcomment_types = { 'tmux': '# ' }
"}}}
Plug 'kana/vim-textobj-user', { 'for': 'ruby' } " only used for vim-textobj-rubyblock
Plug 'nelstrom/vim-textobj-rubyblock', { 'for': 'ruby' }
Plug 'Raimondi/delimitMate'
Plug 'zaiste/tmux.vim' " tmux syntax
Plug 'digitaltoad/vim-jade'
Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim', { 'on': 'Gist' } "{{{
  let g:gist_detect_filetype = 1
  let g:gist_open_browser_after_post = 1
"}}}
Plug 'nsf/gocode', { 'rtp': 'vim/' }
Plug 'fatih/vim-go' "{{{
  let g:go_highlight_functions = 1
  let g:go_highlight_methods = 1
  " let g:go_highlight_structs = 1
  " let g:go_higlight_operators = 1
  let g:go_fmt_fail_silently = 1
  " let g:go_fmt_experimental = 1 " doesn't seem to work
"}}}
Plug 'rking/ag.vim'
Plug 'sentientmachine/Pretty-Vim-Python'
Plug 'fs111/pydoc.vim' "{{{
  let g:pydoc_cmd = 'python -m pydoc'
  let g:pydoc_window_lines=15
"}}}
Plug 'SirVer/ultisnips', { 'on': [] } "{{{
  let g:UltiSnipsExpandTrigger="<C-j>"
  let g:UltiSnipsJumpForwardTrigger="<C-j>"
  let g:UltiSnipsSnippetDirectories=["UltiSnips", "ultisnips"]
"}}}
Plug 'honza/vim-snippets' " snippets collection
Plug 'Valloric/YouCompleteMe', { 'do': './install.sh', 'on': [] } " {{{
  " let g:ycm_complete_in_strings = 0
  let g:ycm_collect_identifiers_from_tags_files = 1
  let g:ycm_seed_identifiers_with_syntax = 1
  let g:ycm_autoclose_preview_window_after_insertion = 1
"}}}
Plug 'jmcantrell/vim-virtualenv' "{{{
  let g:virtualenv_auto_activate = 1
"}}}
Plug 'elzr/vim-json'
Plug 'jayflo/vim-skip' "{{{
  " let g:vimskip_wraptocenter = 1
"}}}
Plug 'dag/vim-fish'
Plug 'mhinz/vim-tmuxify' "{{{
  let g:tmuxify_map_prefix = '<leader>t'
"}}}
Plug 'chriskempson/base16-vim'
Plug 'groenewege/vim-less'
Plug 'dart-lang/dart-vim-plugin'
Plug 'vim-scripts/restore_view.vim'
Plug 'vim-scripts/quickhl.vim', { 'on': '<Plug>(quickhl-manual-this)' } "{{{
  nmap <leader>m <Plug>(quickhl-manual-this)
  let g:quickhl_cword_hl_command = 'link QuickhlCword Todo'
"}}}
Plug 'wellle/targets.vim' "{{{
  let g:targets_pairs = '()b {}B []r <> ' " disable 'a' for 'angle-brackets'
"}}}
Plug 'b4winckler/vim-angry'
Plug 'christoomey/vim-tmux-navigator' "{{{
  let g:tmux_navigator_no_mappings = 1
  nnoremap <silent> <C-h> :TmuxNavigateLeft<CR>
  nnoremap <silent> <C-j> :TmuxNavigateDown<CR>
  nnoremap <silent> <C-k> :TmuxNavigateUp<CR>
  nnoremap <silent> <C-l> :TmuxNavigateRight<CR>
  " this doesn't work right now, terminal doesn't see a unique keycap for C-, vs just ,
  " nnoremap <silent> <C-,> :TmuxNavigatePrevious<CR>
"}}}
Plug 'honza/dockerfile.vim'
Plug 'sjl/gundo.vim', { 'on': 'GundoToggle' } "{{{
  nnoremap <leader>u :GundoToggle<CR>
  let g:gundo_width = 40
  let g:gundo_preview_height = 20
  let g:gundo_close_on_revert = 1
"}}}
Plug 'kylef/apiblueprint.vim'

" Unused {{{
" Plug 'benmills/vimux' "{{{
" 	let g:VimuxPromptString = "vimux> "
" 	let g:VimuxUseNearest = 0
" 	let g:VimuxHeight = 15
" "}}}
" Plug 'greyblake/vim-preview' "{{{
"   " vim-preview (markdown, rdoc, textile, html, ronn, rst)
"   " if(!exists('g:PreviewBrowsers'))
"     if(system("uname") =~ "Darwin")
"       let g:PreviewBrowsers = 'open,google-chrome,safari,firefox'
"     else
"       let g:PreviewBrowsers = 'chromium,firefox,epiphany'
"     endif
"   " endif
"   " remove default mapping and add custom one
"   " autocmd VimEnter * 
"   "   " \ nunmap <leader>P
"   "   \ nmap <silent> <leader>p :Preview<CR>
" "}}}
" Plug 'vim-scripts/ShowMarks'
" Plug 'vim-scripts/highlight.vim'
" Plug 'xolox/vim-lua-ftplugin', {'depends': 'xolox/vim-misc'} "{{{
"   let g:lua_compiler_name = 'luac5.1'
"   let g:lua_interpreter_path = 'lua5.1'
" "}}}
"}}}

call plug#end()

" Manually loaded plugins {{{
augroup plugins_load_insert_enter
  autocmd!
  autocmd InsertEnter * call plug#load('ultisnips', 'YouCompleteMe')
                     \| call youcompleteme#Enable()
                     \| autocmd! plugins_load_insert_enter
augroup END
"}}}

" built-in macros:
runtime macros/matchit.vim

" Enable file type detection.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

"}}}

"------------------------------------------------------------------------------
" Appearance
"------------------------------------------------------------------------------
"{{{

" --- Settings ---
set background=dark
set cursorline
set laststatus=2 " always show the status line
" set t_Co=16
set t_Co=256
" set term=screen-256color

" --- Colorscheme ---
" let g:solarized_termcolors=16
" colorscheme solarized
let g:base16_shell_path="$HOME/.config/base16-shell"
let base16colorspace=256
colorscheme base16-default

" --- Highlights ---
" :h cterm-colors
hi LineNr ctermfg=237 ctermbg=234
" hi CursorLineNr ctermfg=4

" hi cursorline ctermbg=0 gui=bold
hi cursorline ctermbg=234
"
" " Highlight for the omnicompletion menu
" hi Pmenu ctermbg=234 ctermfg=7
"
hi SignColumn ctermbg=234
" hi FoldColumn ctermbg=234
"
" hi Question ctermfg=4
" hi Operator ctermfg=3
" hi MatchParen ctermfg=4
hi Todo term=standout ctermfg=16 ctermbg=18
"
" diff highlight options
hi DiffAdd ctermfg=2 ctermbg=0
hi DiffDelete ctermfg=1 ctermbg=0
hi DiffChange ctermfg=3 ctermbg=0
hi DiffText ctermfg=16 ctermbg=0

" Highlights for status line (must appear after any :colorscheme)
hi User1 ctermbg=black ctermfg=darkgreen guibg=steelblue4 guifg=darkgray  "buffer number
hi User2 ctermbg=black ctermfg=darkred   guibg=black      guifg=darkred   "filetype
hi User3 ctermbg=black ctermfg=darkblue  guibg=gray	      guifg=darkblue  "fugitive(git)
hi User4 ctermbg=red	 ctermfg=white     guibg=red        guifg=white     "syntastic
hi User5 ctermbg=black ctermfg=darkgreen guibg=gray	      guifg=darkgreen "virtualenv

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

function! RenderVirtualenvStatus()
  let venv_stat = virtualenv#statusline()
  if (venv_stat == '')
    return ''
  else
    return '[venv:'.venv_stat.']'
  endif
endfunction

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
set statusline+=\ %5*                         " switch to User5 highlight
set statusline+=%{exists('g:virtualenv_loaded')?RenderVirtualenvStatus():''}
set statusline+=%*\                           " normal highlight

set statusline+=%=                            " right align
set statusline+=%4*                           " switch to User4 highlight
set statusline+=%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}
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

" insert a line above the current line
function! Add_blank_line_above() 
  let failed = append(line('.')-1, "")
endfunction
" C-j used for moving between snippet fields, find a better map
" inoremap <C-j> <C-o>:call Add_blank_line_above()<CR>

" temporary map in order to use instant-markdown
" in a separate terminal run `instant-markdown-d`
" autocmd BufWritePost *.md,*.markdown :silent !cat %:p | curl -X PUT -T - http://localhost:8090/

" experimenting with ESC
" imap jk <ESC>
" imap kj <ESC>

" show trailing spaces and tabs
" set list listchars=tab:\ \ ,trail:·
" set list listchars=tab:\ \ ,trail:»
"}}}
