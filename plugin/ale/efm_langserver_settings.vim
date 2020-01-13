"=============================================================================
" File: efm_langserver_settings.vim
" Author: Tsuyoshi CHO
" Created: 2020-01-11
"=============================================================================

scriptencoding utf-8

if exists('g:loaded_ale_efm_langserver_settings')
          \ || !executable('efm-langserver')
  finish
endif
let g:loaded_ale_efm_langserver_settings = 1

let s:config_dir  = expand('<sfile>:h:h:h') . '/config/efm-langserver'
let s:config_file = expand(s:config_dir . '/config.yaml')
let s:settings    = json_decode(join(readfile(s:config_dir
          \                                   . '/settings.json'), "\n"))

let s:whitelist = []
for s:data in s:settings
  if executable(s:data.cmd)
    call extend(s:whitelist, s:data.whitelist)
  endif
endfor

function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction

function! s:linter_setup() abort
  let lintlist = []
  if exists(b:ale_linters)
    if type(b:ale_linters) is type('')
      let lintlist = [b:ale_linters]
    elseif type(b:ale_linters) is type([])
      let lintlist = b:ale_linters
    else
      " ignore / force overwrite
    endif
  endif
  let b:ale_linters = uniq(sort(lintlist + ['efm-langserver']))
endfunction

augroup ale_efm_langserver_settings
  autocmd!
augroup END
augroup ale_efm_langserver_settings_init
  autocmd!
augroup END

for typename in s:whitelist
  autocmd ale_efm_langserver_settings_init VimEnter *
            \ if get(g:, 'loaded_ale_dont_use_this_in_other_plugins_please', 0)
            \ |  call ale#linter#Define(typename, {
            \     'name': 'efm-langserver',
            \     'lsp': 'stdio',
            \     'executable': 'efm-langserver',
            \     'command': '%e',
            \     'project_root':
            \        {buffer->ale#path#FindNearestDirectory(buffer, '')},
            \   })
            \ | endif

  execute 'autocmd ale_efm_langserver_settings Filetype ' . typename
            \ . ' if get(g:, "loaded_ale_dont_use_this_in_other_plugins_please", 0)'
            \ . ' | call ' . printf('<SNR>%s_', s:_SID()) . 'linter_setup()'
            \ . ' | endif'
endfor
" autocmd ale_efm_langserver_settings_init VimEnter * autocmd! ale_efm_langserver_settings_init

unlet s:config_dir s:config_file s:whitelist s:settings s:data

" EOF
