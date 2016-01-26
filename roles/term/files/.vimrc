" Include default global config
" source /etc/vimrc

" 1,000 lines for copy buffer
set viminfo='20,<1000,s1000

" Remember last line in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Line Numbers
set number

" Highlight all search results
hi Search cterm=NONE ctermfg=black
set hlsearch

" size of a hard tabstop
set tabstop=4

" size of an "indent"
set shiftwidth=4

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4

" always uses spaces instead of tab characters
set expandtab

" auto indent lines
set autoindent

" add an extra indent to python methods, for example
set smartindent
