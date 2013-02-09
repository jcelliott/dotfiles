" Settings for go files

let b:interpreter = 'go run'
set makeprg = "go build %"

" run file through goformat before saving
autocmd BufWritePre *.go :silent Fmt
