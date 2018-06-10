" textobj-function - Text objects for functions
" Version: 0.4.0
" Copyright (C) 2014 Kana Natsuno <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

function! textobj#function#php#select(object_type)
  return s:select_{a:object_type}()
endfunction

function! s:select_a()
  " @todo normal comment before function
  if getline('.') =~# '}'
    normal! k
  endif
  "search down, if not in comment then done
  let x = 0
  while x < 3
    call search('}', 'W')
    let syntype = synIDattr(synID(line('.'), col('.'), 1), "name")
    let syncomment = 0
    if syntype =~ "phpComment" || syntype =~ 'phpDocTags'
      let syncomment = 1
    endif
    if syncomment == 0
      break
    endif
    let x = x+1
  endwhile
  let c = search('function', 'bW')
  let fpos = getpos('.')
  "handle docblock
  if getline(c-1) =~ "*/"
    call search('/\*\*', 'bW')
  endif
  let b = getpos('.')
  call setpos('.', fpos)
  call search('{', 'W')
  normal! $%
  let e = getpos('.')
  if 1 < e[1] - b[1]  " is there some code?
    return ['V', b, e]
  else
    return 0
  endif
endfunction

function! s:select_i()
  let range = s:select_a()
  if range is 0
    return 0
  endif

  let [_, ab, ae] = range

  call setpos('.', ae)

  let ie = getpos('.')
  let ie[1] = ie[1] - 1

  normal! $%

  let ib = getpos('.')
  let ib[1] = ib[1] + 1

  if 0 <= ie[1] - ib[1]  " is there some code?
    return ['V', ib, ie]
  else
    return 0
  endif
endfunction

" __END__  "{{{1
" vim: foldmethod=marker
