
" docstring syntax additions from: http://ianbits.googlecode.com/svn/trunk/vim/python.vim
syn region pythonDocstring  start=+^\s*[uU]\?[rR]\?"""+ end=+"""+ keepend excludenl
syn region pythonDocstring  start=+^\s*[uU]\?[rR]\?'''+ end=+'''+ keepend excludenl

syn keyword pythonSelf self
" don't just use ALL because then we will catch it in comments as well
" syn keyword pythonSelf self containedin=ALL
syn keyword pythonSelf self containedin=pythonParameters


highlight link pythonDocstring Comment
" bold the word 'self'
highlight link pythonSelf Question
highlight link pythonSelf Comment

" dependent on Pretty-Vim-Python plugin
highlight link pythonClass Special
" highlight link pythonClassParameters Underlined
highlight link pythonParameters Underlined

" look here for something better eventually:
" http://stackoverflow.com/questions/18120713/vim-syntax-highlighting-of-doxygen-style-docstrings-in-python

