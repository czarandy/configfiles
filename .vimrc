" Tab settings
set ts=2
set sw=2
set expandtab
set autoindent
set smartindent

" No backups
set nowritebackup
set nobackup

set showcmd
set showmode
set showmatch
set wrap
set ignorecase
set smartcase
set ruler

" Window navigation
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

set nocompatible
set bs=indent,eol,start
set history=50

" Search for tags in parent directories
set tags=tags;/

syntax on

" 80 char columns
set colorcolumn=81
set tw=80

" Ctrl+] shows list of tags
noremap <C-]> g<C-]>

" F4 fixes syntax highlighting
noremap <F4> :syntax off<CR>:syntax on<CR>

" Fix common typos
ca WQ wq
ca Wq wq

inoremap jk <Esc>
inoremap kj <Esc>

" Make \% insert the current filename
nmap <Leader>% "=expand("%:t:r")<C-M>p
imap <Leader>% <c-r>=expand("%:t:r")<C-M>

set undolevels=1000

" Bind 'gb' to 'git blame'
:vmap gb :<C-U>!git blame % -L<C-R>=line("'<") <CR>,<C-R>=line("'>") <CR><CR>
:nmap gb :!git blame %<CR>

" Remove trailing spaces when saving files
autocmd BufWritePre * :%s/\s\+$//e

" Super backspace
set backspace=start,indent,eol

" JS/React features
nmap <Leader>p :!prettier --write %<Enter><Enter>:edit<Enter>
function AutoImport()
  let word = expand("<cword>")
  if (empty(word))
    return
  endif

  let line = getline(".")
  let wordPos = strridx(line, word, col(".") - 1) - 1

  let react = ""
  if wordPos > -1 && line[wordPos] == '<'
    let react = ".react"
  endif
  if wordPos > -1 && line[wordPos] == '/'
    let react = ".react"
  endif

  let cursorPos = getpos(".")

  let foundline = search("import ")
  let newline = "import ".word." from '".word.react."';"
  if !search(newline)
    call append(foundline, newline)
    let cursorPos[1] = cursorPos[1] + 1
  endif

  call setpos(".", cursorPos)
endfunction

map <leader>i :call AutoImport()<cr>
