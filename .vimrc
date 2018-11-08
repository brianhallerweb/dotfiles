runtime! archlinux.vim

call plug#begin()
   Plug 'flazz/vim-colorschemes'
   Plug 'scrooloose/nerdtree'
   Plug 'pangloss/vim-javascript'   
   Plug 'scrooloose/syntastic'
   Plug 'scrooloose/nerdcommenter'
   Plug 'ervandew/supertab'
   Plug 'myusuf3/numbers.vim'
   Plug 'prettier/vim-prettier', { 'do': 'npm install' }   
   Plug 'tpope/vim-surround'
   Plug 'lifepillar/vim-solarized8'
call plug#end()

set background=dark
colorscheme solarized8

:map <C-n> :NERDTree

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_python_exec = '/usr/bin/python3'

vnoremap <C-c> "+y 
map <C-p> "+p

set textwidth=79

"config for nerdcommenter
",cc will comment out selected lines
",c<space> will toggle comments
filetype plugin on
let mapleader=","

