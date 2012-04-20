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

" Fix common typos
ca WQ wq
ca Wq wq

set undolevels=1000

" Bind 'gb' to 'git blame'
:vmap gb :<C-U>!git blame % -L<C-R>=line("'<") <CR>,<C-R>=line("'>") <CR><CR>
:nmap gb :!git blame %<CR>

" Remove trailing spaces when saving files
autocmd BufWritePre * :%s/\s\+$//e
