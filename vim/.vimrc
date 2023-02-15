" vim-plug settings
"##################
call plug#begin()
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mattn/emmet-vim'
Plug 'w0rp/ale'
Plug 'flazz/vim-colorschemes'
Plug 'phanviet/vim-monokai-pro'
Plug 'sainnhe/everforest'
Plug 'sainnhe/gruvbox-material'
Plug 'valloric/youcompleteme'
Plug 'rizzatti/dash.vim'
call plug#end()

" color scheme
set termguicolors
colorscheme monokai_pro

set backspace=indent,eol,start
