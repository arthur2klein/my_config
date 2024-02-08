set term=xterm-256color
filetype plugin indent on

call plug#begin()

"------------------------------------------------------------------------------
" Languages
"------------------------------------------------------------------------------
" LSP
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Debugging
Plug 'puremourning/vimspector'

"------------------------------------------------------------------------------
" Wrinting
"------------------------------------------------------------------------------
" Latex
Plug 'lervag/vimtex'
" Markdown
Plug 'iamcco/markdown-preview.nvim', {'do': 'cd app && npx --yes yarn install'}

"------------------------------------------------------------------------------
" Edition
"------------------------------------------------------------------------------
" Align equation
Plug 'junegunn/vim-easy-align'
" Surround expression
Plug 'tpope/vim-surround'
" Comment line
Plug 'tpope/vim-commentary'
" Formatting
Plug 'vim-autoformat/vim-autoformat'

"------------------------------------------------------------------------------
" File gestion
"------------------------------------------------------------------------------
" Fzzy searching
Plug 'junegunn/fzf', {'do': './install --all' }
" List content of file
Plug 'preservim/tagbar'
" File tree
Plug 'preservim/nerdtree'

"------------------------------------------------------------------------------
" Syntax color
"------------------------------------------------------------------------------
" Kotlin
Plug 'udalov/kotlin-vim'
" Cypher
Plug 'memgraph/cypher.vim'
" CSS Color
Plug 'ap/vim-css-color'
" Svelte
Plug 'evanleck/vim-svelte'
"Freemarker
Plug 'andreshazard/vim-freemarker'

"------------------------------------------------------------------------------
" Theme
"------------------------------------------------------------------------------
" Tokyo night
Plug 'ghifarit53/tokyonight-vim'
" Sonokai
Plug 'sainnhe/sonokai'
" For airline
Plug 'vim-airline/vim-airline-themes'

"------------------------------------------------------------------------------
" Misc
"------------------------------------------------------------------------------
"loremipsum
Plug 'vim-scripts/loremipsum'
" Start screen
Plug 'mhinz/vim-startify'
" Airline
Plug 'vim-airline/vim-airline'
" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Tmux
Plug 'christoomey/vim-tmux-navigator'

call plug#end()

function! Is_wsl()
  if has("unix")
    let lines = readfile("/proc/version")
    if lines[0] =~ "Microsoft"
      return 1
    endif
  endif
  return 0
endfunction

syntax enable
set expandtab
set softtabstop=2
set tabstop=2
set shiftwidth=2
set number relativenumber
set cc=80
set noerrorbells
set nobackup
set nowritebackup
set encoding=utf-8
set updatetime=300
set signcolumn=yes
set incsearch
set hlsearch
set noswapfile
if has('mouse')
  set mouse=a
endif
" Ps = 0  -> blinking block.
" Ps = 1  -> blinking block (default).
" Ps = 2  -> steady block.
" Ps = 3  -> blinking underline.
" Ps = 4  -> steady underline.
" Ps = 5  -> blinking bar (xterm).
" Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
let &t_SR = "\e[4 q"
" Fix the delay when exiting insertion mode
set ttimeout
set ttimeoutlen=1
set ttyfast
" Change C-c to Esc to have the desire output when using <n>i or C-v i
imap <C-c> <Esc>

if Is_wsl()
  set visualbell
  set t_u7=
endif

" Appearance
set termguicolors
" Available values: 'default', 'atlantis', 'andromeda', 'shusia', 'maia',
" 'espresso'
let g:sonokai_style = 'atlantis'
" Available values: 'night', 'storm'
let g:tokyonight_style = 'storm'
colorscheme tokyonight
let g:airline_theme='tokyonight'

" Move line
execute "set <M-j>=\ej"
execute "set <M-k>=\ek"
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

" Startify
" returns all modified files of the current git repo
" `2>/dev/null` makes the command fail quietly, so that when we are not
" in a git repo, the list will be empty
function! s:gitModified()
  let files = systemlist('git ls-files -m 2>/dev/null')
  return map(files, "{'line': v:val, 'path': v:val}")
endfunction

" same as above, but show untracked files, honouring .gitignore
function! s:gitUntracked()
  let files = systemlist('git ls-files -o --exclude-standard 2>/dev/null')
  return map(files, "{'line': v:val, 'path': v:val}")
endfunction

let g:startify_lists = [
      \ { 'type': 'files',     'header': ['   MRU']                        },
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()]             },
      \ { 'type': 'sessions',  'header': ['   Sessions']                   },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']                  },
      \ { 'type': function('s:gitModified'), 'header': ['   git modified'] },
      \ { 'type': function('s:gitUntracked'), 'header': [' git untracked'] },
      \ { 'type': 'commands', 'header': [' Commands']                      },
      \ ]

" Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

nmap <F8> :TagbarToggle<CR>
nmap <F3> :Autoformat<CR>
nnoremap <F2> :NERDTreeToggle<CR>

nnoremap <silent> <C-m> :FZF<CR>

" Latex
" nmap <leader>ml <Plug>vimtex-compile
" nmap <leader>mk <Plug>vimtex-stop

" Markdown
nmap <leader>ml <Plug>MarkdownPreview
nmap <leader>mk <Plug>MarkdownPreviewStop

highlight CocFloating ctermbg=8

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"Stops the cursor from going black when encountering a matching character
highlight MatchParen cterm=bold ctermbg=NONE ctermfg=yellow guibg=NONE guifg=yellow
