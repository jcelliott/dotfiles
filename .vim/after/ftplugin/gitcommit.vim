" Settings for git commit messages

" Best practices for commit messages
" http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
set tw=72

" Start on the first line in insert mode
au BufEnter * call setpos('.', [0,1,1,0])
startinsert

" enable spell check
setlocal spell
