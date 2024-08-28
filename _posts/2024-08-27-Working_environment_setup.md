---
layout:     post
title:      Setup the working environment
date:       2024-08-27
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
toc:
  sidebar: left

tags: Linux

---

## Goal
1. Install and setup `Oh-my-zsh` with plugins.
2. Install and setup VIM with plugins.
3. Install and setup git.
4. Install `Oh-my-TMUX`.
5. Use ctag to generate tags for vim
  
## Install and setup Oh-my-zsh: 
  ```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```
## Install plugins for Oh-my-zsh:
  
  1. Install the theme Powerline10k:
      ```bash
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
      ```
  2. Install plugin zsh-autosuggestions:
      ```bash
      git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
      ```
  3. Install plugin zsh-syntax-highlighting:
      ```bash
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
      ```
  4. update the plugin section in your ~/.zshrc file:
      ```bash
      ZSH_THEME="powerlevel10k/powerlevel10k" #place your theme with powerline10k
      plugins=( 
        # other plugins...
        zsh-syntax-highlighting
        zsh-autosuggestions)
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#19a9ec,bold,underline"
        source $ZSH/oh-my-zsh.sh
        # Bindkey
        bindkey '^j' autosuggest-accept # ctrl+j to accept suggestion.
      ```
  5. Install the Tmux2 plugin(optional):
      ```bash
      plugins=(
        # other plugins
        tmux
      )
      ZSH_TMUX_AUTOSTART=true # auto start tmux session.
      ```
## Install Vim/nvim with plugins
{% include note.html content="Some plugins such as verible-verilog-ls needs VIM9 to show the warning during editing." %}

  1. nvim could be easily installed on ubuntu: ```sudo apt install neovim```
  2. nvim could use your ~/.vimrc file by adding following into your `~/.config/nvim/init.vim`:
      ```bash
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath=&runtimepath
      source ~/.vimrc
      ```
  3. Install Vundle to manage VIM plugins: 
      ```bash
      git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      ```
      put the following into your `~/.vimrc`, create the file if you don't have one.
      ```
      set tabstop = 2
      set shiftwidth = 2
      set expandtab = 2
      syntax enable
      set nocompatible              " be iMproved, required
      filetype off                  " required
      let mapleader = ","
      let g:NERDTreeWinPos = "bottom"
      let NERDTreeShowHidden = 0
      let NERDTreeIgnore = ['\.pyc$', '__pycache__']
      let g:NERDTreeWinSize = 15
      map <leader>nn :NERDTreeToggle<cr>
      map <leader>nb :NERDTreeFromBookmark
      map <leader>nf :NERDTreeFind<cr>
      map <leader>f  :Files<CR>
      " set the runtime path to include Vundle and initialize
      set rtp+=~/.vim/bundle/Vundle.vim
      call vundle#begin()
      " alternatively, pass a path where Vundle should install plugins
      "call vundle#begin('~/some/path/here')

      " let Vundle manage Vundle, required

      " My vim plugins:
      Plugin 'VundleVim/Vundle.vim'
      Plugin 'preservim/nerdcommenter.vim'
      Plugin 'preservim/nerdtree.vim'
      Plugin 'jiangmiao/autopairs.vim'
      Plugin 'skywind3000/vim-auto-popmenu'
      Plugin 'airblade/vim-gitgutter'
      Plugin 'prabirshrestha/vim-lsp'
      Plugin 'junegunn/fzf'
      Plugin 'junegunn/fzf.vim'

      " All of your Plugins must be added before the following line
      call vundle#end()            " required
      filetype plugin indent on    " required
      " To ignore plugin indent changes, instead use:
      "filetype plugin on
      inoremap <expr> <Tab>  pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <expr> <S-Tab>  pumvisible() ? "\<C-p>" : "\<S-Tab>"
      set completeopt=menu,menuone,noselect

      "
      " Brief help
      " :PluginList       - lists configured plugins
      " :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
      " :PluginSearch foo - searches for foo; append `!` to refresh local cache
      " :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
      "
      " see :h vundle for more details or wiki for FAQ
      " Put your non-Plugin stuff after this line
      " This section to the end is optional, add it if you want to use verible-verilog-ls with vim.
      if executable('verible-verilog-ls')
          au User lsp_setup call lsp#register_server({
              \ 'name': 'verible-verilog-ls',
              \ 'cmd': {server_info->[PATH_TO_VERIBLE_VERILOG_LS]},
              \ 'allowlist': ['verilog', 'systemverilog'],
              \ })
      endif
      function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        setlocal signcolumn=yes
        if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> gs <plug>(lsp-document-symbol-search)
        nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
        nmap <buffer> gr <plug>(lsp-references)
        nmap <buffer> gi <plug>(lsp-implementation)
        nmap <buffer> gt <plug>(lsp-type-definition)
        nmap <buffer> <leader>rn <plug>(lsp-rename)
        nmap <buffer> [g <plug>(lsp-previous-diagnostic)
        nmap <buffer> ]g <plug>(lsp-next-diagnostic)
        nmap <buffer> K <plug>(lsp-hover)
        nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
        nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

        let g:lsp_format_sync_timeout = 1000
        autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
        
        " refer to doc to add more commands
      endfunction

      augroup lsp_install
          au!
          " call s:on_lsp_buffer_enabled only for languages that has the server registered.
          autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
      augroup END
      ```

## Install and setup git

  1. Install: ```sudo apt install git-all```
  2. Setup:
      ```
      git config --global --get user.email
      git config --global pull.rebase true
      git config --global diff.tool vimdiff
      git config --global difftool.prompt false
      git config merge.tool vimdiff
      git config merge.conflictstyle diff3
      git config mergetool.prompt false
      ```
  [!Note] Use `git log --all --decorate --oneline --graph` to show a nice git commit history.

## Install Tmux
  ```bash
  $ git clone https://github.com/gpakosz/.tmux.git "/path/to/oh-my-tmux"
  $ mkdir -p "~/.config/tmux"
  $ ln -s "/path/to/oh-my-tmux/.tmux.conf" "~/.config/tmux/tmux.conf"
  $ cp "/path/to/oh-my-tmux/.tmux.conf.local" "~/.config/tmux/tmux.conf.local"
  ```

## Install ctags with VIM
    ```bash
      $ git clone https://github.com/universal-ctags/ctags.git
      $ cd ctags
      $ ./autogen.sh
      $ ./configure  # use --prefix=/where/you/want to override installation directory, defaults to /usr/local
      $ make
      $ make install # may require extra privileges depending on where to install
    ```
    Get into the root directory of your project and run ```ctags -R *``` to generate the tags file.

    Put following line into your `~/.vimrc` file to automatically load the tags file:
    ```bash
    set tags=./tags;,tags;
    ```

  Now you can use `ctrl + ]` to jump to the defination of function/variable. Use `ctrl+ t` to go back.

  [!note] Added ```nnoremap <C-]> :tag <C-R><C-W><CR>``` into your `~/.vimrc` to avoid the lazy load of tags file.
