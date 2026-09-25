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

" Reload files changed by other processes while Vim is open.
set autoread
augroup external_file_changes
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold * checktime
augroup END

" TypeScript language server
if executable('typescript-language-server')
  let g:lsp_diagnostics_enabled = 0
  let g:lsp_document_code_action_signs_enabled = 0
  let g:lsp_document_highlight_enabled = 0
  let g:lsp_signature_help_enabled = 0
  let g:lsp_use_native_client = 1

  " tsserver can retain a failed import lookup after a new source file appears.
  " Watch source directories and refresh the project once new files settle.
  if executable('inotifywait')
    if exists('g:typescript_lsp_watch_job') && type(g:typescript_lsp_watch_job) == v:t_job
      if job_status(g:typescript_lsp_watch_job) ==# 'run'
        call job_stop(g:typescript_lsp_watch_job)
      endif
    endif
    if get(g:, 'typescript_lsp_watch_timer', -1) > 0
      call timer_stop(g:typescript_lsp_watch_timer)
    endif
    let g:typescript_lsp_watch_job = v:null
    let g:typescript_lsp_watch_root = ''
    let g:typescript_lsp_watch_timer = -1
    let g:typescript_lsp_restart_pending = 0
    let g:typescript_lsp_activate_pending = 0

    function! s:RestartTypeScriptAfterNewFile(timer) abort
      let g:typescript_lsp_watch_timer = -1
      let l:status = lsp#get_server_status('typescript-language-server')
      if l:status ==# 'starting'
        let g:typescript_lsp_watch_timer = timer_start(1000, function('s:RestartTypeScriptAfterNewFile'))
      elseif l:status ==# 'running'
        let g:typescript_lsp_restart_pending = 1
        call lsp#stop_server('typescript-language-server')
      endif
    endfunction

    function! s:OnNewTypeScriptFile(channel, path) abort
      if a:path !~# '\.\%(ts\|tsx\|mts\|cts\)$'
        return
      endif
      if g:typescript_lsp_watch_timer > 0
        call timer_stop(g:typescript_lsp_watch_timer)
      endif
      let g:typescript_lsp_watch_timer = timer_start(1500, function('s:RestartTypeScriptAfterNewFile'))
    endfunction

    function! s:StartTypeScriptFileWatcher() abort
      if !lsp#is_server_running('typescript-language-server')
        return
      endif
      let l:root = lsp#utils#uri_to_path(lsp#get_server_root_uri('typescript-language-server'))
      if l:root ==# g:typescript_lsp_watch_root && type(g:typescript_lsp_watch_job) == v:t_job
        if job_status(g:typescript_lsp_watch_job) ==# 'run'
          return
        endif
      endif
      if type(g:typescript_lsp_watch_job) == v:t_job && job_status(g:typescript_lsp_watch_job) ==# 'run'
        call job_stop(g:typescript_lsp_watch_job)
      endif
      let l:paths = []
      for l:dir in ['src', 'app', 'lib', 'e2e', 'tests', 'scripts']
        if isdirectory(l:root . '/' . l:dir)
          call add(l:paths, l:root . '/' . l:dir)
        endif
      endfor
      let l:command = ['inotifywait', '-m', '-q', '-e', 'create,moved_to', '--format', '%w%f']
      if empty(l:paths)
        let l:paths = [fnamemodify(expand('%:p'), ':h')]
      else
        call add(l:command, '-r')
      endif
      let g:typescript_lsp_watch_root = l:root
      let g:typescript_lsp_watch_job = job_start(
            \ l:command + l:paths,
            \ {'out_cb': function('s:OnNewTypeScriptFile'), 'out_mode': 'nl', 'err_io': 'null'})
    endfunction

    function! s:ReactivateTypeScriptAfterRefresh() abort
      if !g:typescript_lsp_restart_pending
        return
      endif
      let g:typescript_lsp_restart_pending = 0
      if index(['typescript', 'typescriptreact'], &filetype) >= 0
        call lsp#activate()
      else
        let g:typescript_lsp_activate_pending = 1
      endif
    endfunction

    function! s:ActivateTypeScriptIfPending() abort
      if g:typescript_lsp_activate_pending && index(['typescript', 'typescriptreact'], &filetype) >= 0
        let g:typescript_lsp_activate_pending = 0
        call lsp#activate()
      endif
    endfunction

    augroup typescript_lsp_file_watcher
      autocmd!
      autocmd User lsp_buffer_enabled call <SID>StartTypeScriptFileWatcher()
      autocmd User lsp_server_exit call <SID>ReactivateTypeScriptAfterRefresh()
      autocmd BufEnter *.ts,*.tsx,*.mts,*.cts call <SID>ActivateTypeScriptIfPending()
    augroup END
  endif

  augroup typescript_lsp
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'typescript-language-server',
          \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
          \ 'root_uri': {server_info->lsp#utils#path_to_uri(
          \   lsp#utils#find_nearest_parent_file_directory(
          \     lsp#utils#get_buffer_path(),
          \     ['tsconfig.json', 'package.json', '.git']
          \   ))},
          \ 'initialization_options': {'maxTsServerMemory': 4096},
          \ 'allowlist': [
          \   'typescript',
          \   'typescriptreact'
          \ ],
          \ })
    autocmd User lsp_buffer_enabled nmap <buffer> gd <plug>(lsp-definition)
    autocmd User lsp_buffer_enabled nmap <buffer> K <plug>(lsp-hover)
  augroup END
endif

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
