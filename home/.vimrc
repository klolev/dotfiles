let mapleader = " "
set nocompatible
set number "shows line number
set visualbell
set encoding=utf-8
set showmatch "highlight matching (){}[]
set scrolloff=3 "number of lines to show beneath the current line
set mouse=a
set cursorline "underlines the current line
set lazyredraw

set tabstop=4 "number of spaces to display per tab
set expandtab "use spaces
set shiftwidth=4 "affects << and >>
set softtabstop=4 "number of spaces to insert on tab

set backspace=indent,eol,start "use backspace

set foldmethod=syntax
let javaScript_fold=1 "activate folding by JS syntax
set foldlevelstart=99 "start file with all folds opened

nnoremap <leader>O <cmd>Telescope find_files<cr>
nnoremap <leader>F <cmd>Telescope live_grep<cr>
nnoremap <leader>FF <cmd>NvimTreeFindFile<cr>
