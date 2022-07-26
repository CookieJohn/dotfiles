let mapleader=","
let maplocalleader=" "

" let g:python_host_prog='/usr/bin/python'
" let g:python3_host_prog='/usr/local/bin/python3'

" let g:nord_underline=1
" let g:nord_bold=1
" let g:nord_italic=1

" Plugin
call plug#begin()
Plug 'ssh://git@gitlab.abagile.com:7788/abagile/vim-abagile.git'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-rails' ", {'for': ['ruby', 'haml', 'eruby', 'coffee']}
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdtree'
" Plug 'dracula/vim', {'as': 'dracula'}
" Plug 'arcticicestudio/nord-vim'
Plug 'Shougo/denite.nvim'
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'dense-analysis/ale'
Plug 'Yggdroot/indentLine'
Plug 'michaeljsmith/vim-indent-object'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
Plug 'slim-template/vim-slim' ", {'for': ['slim']}
Plug 'vim-ruby/vim-ruby' ", {'for': ['ruby', 'haml', 'eruby']}
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fireplace'
Plug 'Olical/conjure'
Plug 'junegunn/rainbow_parentheses.vim'
" Plug 'eraserhd/parinfer-rust', {'commit': '5def45e1cbbc4f690fe70e44c786ad6bf9437476', 'do': 'cargo build --release'}
Plug 'eraserhd/parinfer-rust', {'do': 'cargo build --release'}
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
" Plug 'clojure-vim/clojure.vim'
Plug 'snoe/clj-refactor.nvim'
Plug 'pearofducks/ansible-vim'
Plug 'ap/vim-css-color'

" abagile specific
Plug 'tyru/vim-altercmd'
" Plug '~/proj/vim-abagile'
Plug 'zefei/simple-dark'
call plug#end()

" silent! color dracula

" augroup nord-theme-overrides
"   autocmd!
"   autocmd ColorScheme nord highlight Comment ctermfg=14 guifg=#8FBCBB
" augroup END
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END
" silent! color nord
silent! color simple-dark

" silent! color base16-eva

set hidden
set hlsearch
set nowrap
set cursorline
set nostartofline
set noswapfile
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set ignorecase
set smartcase
set relativenumber
set regexpengine=1

set scrolloff=1
set sidescrolloff=5

set winfixwidth

set undofile
set undolevels=5000

set matchpairs+=<:>

set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" return to last edit position when opening files
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

autocmd BufRead,BufNewFile *.yml setlocal spell
autocmd BufRead,BufNewFile */playbooks/*.yml set filetype=yaml.ansible

autocmd BufRead,BufNewFile *.thor set filetype=ruby

autocmd FileType markdown setlocal wrap
autocmd FileType eruby.yaml setlocal commentstring=#\ %s

let g:gitgutter_enabled=1
let g:indentLine_enabled=1
let g:NERDTreeQuitOnOpen=1
set wildignore+=*/.git/*,*/node_modules/*
let g:deoplete#enable_at_startup=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_nr_show=1
" let g:airline_theme='nord'
let g:airline_powerline_fonts=1
let test#strategy='dispatch'
let g:dispatch_quickfix_height=20

let g:ale_linters = {
  \ 'clojure': ['clj-kondo']
  \}
let g:ale_warn_about_trailing_whitespace = 1

" Clojure development settings
autocmd CompleteDone * pclose

" augroup rainbow_lisp
"   autocmd!
"   autocmd FileType lisp,clojure,scheme RainbowParentheses
" augroup END

autocmd FileType clojure set iskeyword-=.
autocmd FileType clojure set iskeyword-=/
autocmd FileType clojure setlocal commentstring=;;%s
autocmd FileType clojure setlocal formatoptions+=r

let g:sexp_enable_insert_mode_mappings = 0

let g:clojure_fuzzy_indent_patterns = ['.']
let g:clojure_fuzzy_indent_blacklist = ['->$', '->>$']

let g:conjure#log#hud#height=0.2
autocmd User ConjureEval if expand("%:t") =~ "^conjure-log-" | exec "normal G" | endif

let abagile_cljs_wc_dirs = ['spa', 'b2b', 'b2c', 'inquiry', 'asuka']   " only 'core.cljs' directly under those directories are considered valid
command! -nargs=? WriteCore call abagile#cljs#write_core(<f-args>)
cnoreabbrev wc WriteCore

nnoremap <localleader>cs :call abagile#cljs#setup_cljs_plugin_connection()<CR>

" Key mappings
nnoremap ' `
nnoremap ` '
inoremap jj <esc>
inoremap jk <esc>
inoremap ,, <esc>
nnoremap <Tab> :bnext!<CR>
nnoremap <S-Tab> :bprev!<CR>
nnoremap <leader>w <c-w>
noremap <c-h> <c-w>h
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l

noremap  <up>    <nop>
noremap  <down>  <nop>
noremap  <left>  <nop>
noremap  <right> <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

nnoremap <leader>f :NERDTreeFind<CR>
nnoremap <leader>d :NERDTreeToggle<CR>

nnoremap <leader>bp obinding.pry<esc>

" nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>sa :Ag<CR>
nnoremap <leader>sb :Buffers<CR>
nnoremap <leader>sc :Commits<CR>
nnoremap <leader>sf :Files<CR>
nnoremap <leader>sl :Lines<CR>

nnoremap <leader>g  :GitGutterToggle<CR>
nnoremap <leader>ew :e <C-R>=expand('%:h').'/'<CR>
nnoremap <leader>es :sp <C-R>=expand('%:h').'/'<CR>
nnoremap <leader>ev :vsp <C-R>=expand('%:h').'/'<CR>
nnoremap <leader>et :tabe <C-R>=expand('%:h').'/'<CR>

vmap <Enter> <Plug>(EasyAlign)

" start insert at indentation of above line
nnoremap ,> cc<C-R>=repeat(' ', indent(line('.') - 1) - col('.') + 1)<CR>
inoremap ,> <C-R>=repeat(' ', indent(line('.') - 1) - col('.') + 1)<CR>

" rails test
nnoremap <silent> <Leader>tn :TestNearest<CR>
nnoremap <silent> <Leader>tf :TestFile<CR>
nnoremap <silent> <Leader>ts :TestSuite<CR>
nnoremap <silent> <Leader>tl :TestLast<CR>
nnoremap <silent> <Leader>tv :TestVisit<CR>

" john
set termguicolors
