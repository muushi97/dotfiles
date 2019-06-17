"setlocal foldmethod=expr
"setlocal foldexpr=CppFoledLevel(v:lnum)

"" 蜜柑
"function! CppFoldLevel(lnum)
"    "let previous = getline(a:lnum - 1)
"    let now = getline(a:lnum)
"    "let next = getline(a:lnum + 1)
"
"    "if now =~ 'aaaaa\{1}'
"    "    if previsous =~ 'aaaaa\{1}'
"    "        return '='
"    "    else
"    "        return 'a1'
"    "    endif
"    "elseif previous =~ 'aaaaa\{1}'
"    "    return 's1'
"    "endif
"    "if now =~ 'aaaaa\{1}'
"    "    return 1
"    "
"    if now =~ '{\{1}'
"        return 'a1'
"    elseif now =~ '}\{1}'
"        return 's1'
"    else
"        return '='
"    endif
"endfunction

