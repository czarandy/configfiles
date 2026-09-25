Various .files

## Vim TypeScript LSP

The Vim config uses `vim-lsp` and `typescript-language-server` for TypeScript
navigation. Install them on macOS with:

```sh
brew install typescript-language-server
mkdir -p ~/.vim/pack/lsp/start
git clone https://github.com/prabirshrestha/vim-lsp.git \
  ~/.vim/pack/lsp/start/vim-lsp
```

In a TypeScript or TSX buffer, `gd` jumps to the definition in the current
window. Use `Ctrl-O` to jump back.

On Linux, install `inotify-tools` to keep navigation current when new TypeScript
files are added under `src`, `app`, `lib`, `e2e`, `tests`, or `scripts`. Vim
debounces these events and restarts the language server automatically.
