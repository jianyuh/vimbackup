"set tw = 80 (set 80 characters for one line)
":retab to manually expand tab into 4 spaces
":vertical terminal (split vim editor with a terminal)
"add text at the end of each line in Vim?::%s/$/,/ OR vip<C-V>$A,<Esc>
"After :set=80, choose the text, then "gqq

set cinkeys-=0#               "indent for #pragma: http://stackoverflow.com/questions/12469463/vim-c-back-indent-with

set nocompatible              " be iMproved, required
silent! filetype off          " required by Vundle (silent: avoids E216 on first start)

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line



" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2011 Apr 15
" Modified:    Jianyu Huang <jianyu@cs.utexas.edu>
" Last change: 2014 Apr 8
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use :retab to manually expand tab into 4 spaces
" set tw=0  "unset textwidth option
" set tw=79 "set textwidth = 79
" set tw=80
set tabstop=4
set shiftwidth=4 "tab is 4 space
set backspace=2 "set backspace=indent,eol,start
set expandtab "auto expand tab to space, http://vim.wikia.com/wiki/Converting_tabs_to_spaces
set nu "show the line number

set background=dark "my background
colorscheme desert "my colorscheme

map <F12> :!python %
map <F9> :!pdflatex %
nnoremap <F8> :setl noai nocin nosi inde=<CR>

" Frequent Usage
" :Tlist
" :NERDTree


" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Keep backup/swap/undo files out of the working directories
for s:d in ['backup', 'swap', 'undo']
  if !isdirectory(expand('~/.vim/tmp/' . s:d))
    call mkdir(expand('~/.vim/tmp/' . s:d), 'p')
  endif
endfor
set backup		" keep a backup file
set backupdir=~/.vim/tmp/backup//
set directory=~/.vim/tmp/swap//
set undodir=~/.vim/tmp/undo//
set undofile

" Share the system clipboard (macOS pasteboard) when available
if has('clipboard')
  set clipboard=unnamed
endif
set history=100		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on

  " Modified by Jianyu
  au BufNewFile,BufRead *.txx set  filetype=cpp
  au BufNewFile,BufRead *.cu  set  filetype=cpp
  au BufNewFile,BufRead *.cl  set  filetype=cpp
  "au BufNewFile,BufRead *.cl  setf opencl

  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

 "Set mapleader
 let mapleader = ","

 "Fast reloading of the .vimrc
 map <silent> <leader>ss :source ~/.vimrc<cr>
 "Fast editing of .vimrc
 map <silent> <leader>ee :e ~/.vimrc<cr>
 "When .vimrc is edited, reload it
 autocmd! bufwritepost .vimrc,vimrc source ~/.vimrc

"Pydiction Plugin"
filetype plugin on
let g:pydiction_location = '~/.vim/after/ftplugin/pydiction/complete-dict'
let g:pydiction_menu_height = 20
"set autoindent
syntax enable
"set softtabstop=4
"set shiftwidth=2
"The following is referred to vim.wikia.com/wiki/Folding
"zc close a fold
"zo open a fold
"za toggle the current fold: close if it was open, or open it if it was closed
"zC, zO, zA: domain: all folds (Nested outside)
"zr reduces folding by opening one more level of folds throughout the whole
"buffer.
"zR open all folds
"zm give more folding by closing one more level of folds throughout the whole
"buffer
"zM close all folds
set foldmethod=indent
set foldlevel=10
set autowrite

""Taglist Setting
"":NERDTree
"let Tlist_Ctags_Cmd='/usr/bin/ctags'
"let Tlist_Show_One_File=1
"let Tlist_OnlyWindow=1
"let Tlist_Use_Right_Window=0
"let Tlist_Sort_Type='name'
"let Tlist_Exit_OnlyWindow=1
"let Tlist_Show_Menu=1
"let Tlist_Max_Submenu_Items=10
"let Tlist_Max_Tag_length=20
"let Tlist_Use_SingleClick=0
"let Tlist_Auto_Open=0
"let Tlist_Close_On_Select=0
"let Tlist_File_Fold_Auto_Close=1
"let Tlist_GainFocus_On_ToggleOpen=0
"let Tlist_Process_File_Always=1
"let Tlist_WinHeight=10
"let Tlist_WinWidth=18
"let Tlist_Use_Horiz_Window=0
"map <silent> <leader>tl :TlistToggle<CR>

""""""""""""""""""""""""""""""
" BufExplorer
""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize = 30  " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.
autocmd BufWinEnter \[Buf\ List\] setl nonumber 

"""V undle: Github management plugin for  plugin
"set nocompatible " be iMproved
"filetype off " required!
"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()

