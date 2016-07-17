" Settings for python files

let b:interpreter = 'python'
let b:repl = 'python'
set tabstop=4
set softtabstop=4
set shiftwidth=4

let g:syntastic_python_checkers = ['python', 'pylint', 'pycodestyle']

" Add site-packages from virtualenv to vim path
" py << EOF
" import os.path
" import sys
" import vim
" if 'VIRTUAL_ENV' in os.environ:
"     project_base_dir = os.environ['VIRTUAL_ENV']
"     sys.path.insert(0, project_base_dir)
"     activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"     execfile(activate_this, dict(__file__=activate_this))
" EOF

