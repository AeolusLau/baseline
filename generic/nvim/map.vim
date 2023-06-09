" spell-checker: disable

let mapleader = " "

" Fix the wired key interpretion of shift-tab in Warp.
" https://github.com/warpdotdev/Warp/issues/903
"map  <C-y> <S-Tab>
"map! <C-y> <S-Tab>

" Switch ` & '
nnoremap ' `
nnoremap ` '

" Switch 0 & ^
nnoremap 0 ^
nnoremap ^ 0

" Command to sort the following lines:
"  :sort i /.*map \(.silent.\)\? *\(.expr.\)\? \?/
nnoremap                (                [(
nnoremap                )                ])
inoremap <silent><expr> <C-b>            coc#pum#visible() ? coc#pum#scroll(0) : "\<C-b>"
inoremap <silent><expr> <C-f>            coc#pum#visible() ? coc#pum#scroll(1) : "\<C-f>"
inoremap                <C-h>            <Left>
inoremap                <C-j>            <Down>
inoremap                <C-k>            <Up>
inoremap                <C-l>            <Right>
inoremap <silent><expr> <C-n>            coc#pum#visible() ? coc#pum#next(1) : coc#refresh()
inoremap <silent><expr> <C-p>            coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"
inoremap <silent><expr> <C-y>            exists('b:_codeium_completions') ? codeium#Accept() : "\<C-y>"
    nmap                <C-s>            <Plug>(coc-range-select)
    xmap                <C-s>            <Plug>(coc-range-select)
inoremap <silent><expr> <CR>             coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    nmap <silent>       <leader>/        :nohlsearch<CR>
    nmap                <leader><space>  :<C-u>CocList<CR>
    vmap <silent>       <leader>a        <Plug>(coc-codeaction-selected)
    nmap <silent>       <leader>a        <Plug>(coc-codeaction-selected)
    nmap <silent>       <leader>ac       <Plug>(coc-codeaction-cursor)
    nmap <silent>       <leader>as       <Plug>(coc-codeaction-source)
    nmap                <leader>b        :<C-u>CocCommand fzf-preview.AllBuffers<CR>
    nmap                <leader>d        :<C-u>CocCommand fzf-preview.GitStatus<CR>
    nmap                <leader>f        :<C-u>CocList files<CR>
    nmap                <leader>j        :<C-u>CocCommand fzf-preview.Jumps<CR>
    nmap                <leader>lf       :<C-u>CocListFirst<CR>
    nmap                <leader>ll       :<C-u>CocListLast<CR>
    nmap                <leader>ln       :<C-u>CocListNext<CR>
    nmap                <leader>lp       :<C-u>CocListPrev<CR>
    nmap                <leader>lr       :<C-u>CocListResume<CR>
    nmap <silent>       <leader>o        :CocCommand explorer --preset floating<CR>
nnoremap                <leader>p        "+p
    nmap                <leader>r        :<C-u>CocList grep<CR>
    nmap                <leader>re       <Plug>(coc-codeaction-refactor)
    nmap                <leader>rf       <Plug>(coc-refactor)
    nmap                <leader>rg       :<C-u>CocCommand fzf-preview.ProjectGrep <C-r><C-w><CR>
    nmap                <leader>rn       <Plug>(coc-rename)
    nmap                <leader>sb       :<C-u>CocList -I symbols<CR>
    nmap                <leader>sw       :CocCommand clangd.switchSourceHeader<CR>
nnoremap                <leader>w        :w<CR>
nnoremap                <leader>W        :wa<CR>
vnoremap                <leader>y        "+y
nnoremap                <leader>y        "+y
    nmap                <leader>z        :<C-u>CocList mru<CR>
nnoremap <silent>       <S-Tab>          :bprevious<CR>
inoremap         <expr> <S-Tab>          coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
nnoremap <silent>       <Tab>            :bnext<CR>
    nmap <silent>       ==               :call CocActionAsync('format')<CR>
    nmap                [[               <Plug>(coc-diagnostic-prev)
    nmap                ]]               <Plug>(coc-diagnostic-next)
    xmap                ac               <Plug>(coc-classobj-a)
    omap                ac               <Plug>(coc-classobj-a)
    xmap                af               <Plug>(coc-funcobj-a)
    omap                af               <Plug>(coc-funcobj-a)
    nmap                cm               :<C-u>CocCommand<CR>
    nmap <silent>       co               :call BDeleteOther()<CR>
    nmap <silent>       cx               :bp\|bd#<CR>
    xmap                ga               <Plug>(EasyAlign)
    nmap                ga               <Plug>(EasyAlign)
    nmap                gd               <Plug>(coc-definition)
    nmap                gi               <Plug>(coc-implementation)
    nmap <silent>       gqgq             :call CocActionAsync('fixAll')<CR>
    nmap                gqq              <Plug>(coc-fix-current)
    nmap                gr               <Plug>(coc-references)
    nmap <silent>       gs               :CocCommand fzf-preview.GitStatus<CR>
    nmap                gy               <Plug>(coc-type-definition)
    xmap                ic               <Plug>(coc-classobj-i)
    omap                ic               <Plug>(coc-classobj-i)
    xmap                if               <Plug>(coc-funcobj-i)
    omap                if               <Plug>(coc-funcobj-i)
tnoremap                jk               <C-\><C-n>
inoremap                jk               <Esc>
    nmap <silent>       K                :call ShowDocumentation()<CR>
    nmap <silent>       vs               :source $MYVIMRC<CR>
    nmap <silent>       vv               :e $MYVIMRC<CR>
nnoremap                {                b{w
nnoremap                }                }w

inoremap <silent><expr> <Tab>            coc#pum#visible() ? coc#pum#next(1) :
                                       \ exists('b:_codeium_completions') ? codeium#Accept() :
                                       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
                                       \ CheckBackspace() ? "\<Tab>" :
                                       \ coc#refresh()

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! BDeleteOther()
    let l:buffers = filter(getbufinfo(), {_, v -> v.listed && v.hidden && !v.changed})
    if !empty(l:buffers)
        execute 'bdelete' join(map(l:buffers, {_, v -> v.bufnr}))
    endif
endfunction
