"           _              
"     _  __(_)_ _  ________
"   _| |/ / /  ' \/ __/ __/
" G(_)___/_/_/_/_/_/  \__/ 
"                        
" Joshua Elliott
" Created 2/14/13
"
"------------------------------------------------------------------------------
" GUI Settings
"------------------------------------------------------------------------------

:set guioptions+=a
:set guioptions+=c
:set guioptions+=g
:set guioptions-=T
:set guioptions-=r
:set guioptions-=R
:set guioptions-=l
:set guioptions-=L
:set guioptions-=b

" Set font for gui versions of vim
if has("gui_gtk2")
  set guifont=Luxi\ Mono\ 12
" elseif has("gui_win32")
"   set guifont=Luxi_Mono:h12:cANSI
elseif has("gui_macvim")
  set guifont=Monaco:h12
endif
