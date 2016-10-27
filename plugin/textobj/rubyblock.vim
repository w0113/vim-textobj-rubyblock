if exists('g:loaded_textobj_rubyblock')  "{{{1
  finish
endif

" Interface  "{{{1
call textobj#user#plugin('rubyblock', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'ar',  '*select-a-function*': 's:select_a',
\        'select-i': 'ir',  '*select-i-function*': 's:select_i'
\      }
\    })

" Groups of block openers.  "{{{1
let s:bo_1 = '<begin>|<case>|<class>|<def>|<if>|<module>|<unless>'
let s:bo_2 = '<for>|<until>|<while>' " => optional do
let s:bo_3 = '<do>'

" Build start pattern.  "{{{1
let s:first_kw = '^(\s*|\s*[^#\s].{-};\s*)'

let s:bo_c_1 = s:first_kw . '(' . s:bo_1 . ')\zs'
let s:bo_c_2 = s:first_kw . '(' . s:bo_2 . ')(.{-}<do>)?\zs'
let s:bo_c_3 = '\s*[^#\s].{-}(' . s:bo_3 . ')\zs'
let s:start_pattern = '\v' . s:bo_c_1 . '|' . s:bo_c_2 . '|' . s:bo_c_3

" Build end and skip pattern.  "{{{1
let s:end_pattern = '\v' . s:first_kw . '\zs<end>'

let s:skip_pattern = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'

" select_a, select_i  "{{{1
function! s:select_a()
  let s:flags = 'W'

  call searchpair(s:start_pattern,'',s:end_pattern, s:flags, s:skip_pattern)
  let end_pos = getpos('.')

  " Jump to match
  normal %
  let start_pos = getpos('.')

  return ['V', start_pos, end_pos]
endfunction

function! s:select_i()
  let s:flags = 'W'
  if expand('<cword>') == 'end'
    let s:flags = 'cW'
  endif

  call searchpair(s:start_pattern,'',s:end_pattern, s:flags, s:skip_pattern)

  " Move up one line, and save position
  normal k^
  let end_pos = getpos('.')

  " Move down again, jump to match, then down one line and save position
  normal j^%j
  let start_pos = getpos('.')

  return ['V', start_pos, end_pos]
endfunction

" Fin.  "{{{1

let g:loaded_textobj_rubyblock = 1

" __END__
