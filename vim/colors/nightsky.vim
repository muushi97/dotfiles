hi clear

if exists("syntax on")
syntax reset
endif

set t_Co=256
let g:colors_name = "nightsky"


let s:NUMBER_TYPE = type(0)
function! s:hi(name, fg, bg, attr) abort
    let has_fg = type(a:fg) != s:NUMBER_TYPE
    let has_bg = type(a:bg) != s:NUMBER_TYPE

    let guifg   = has_fg ? ('guifg=' . a:fg[0]) : ''
    let guibg   = has_bg ? ('guibg=' . a:bg[0]) : ''
    let ctermfg = has_fg ? ('ctermfg=' . a:fg[1]) : ''
    let ctermbg = has_bg ? ('ctermbg=' . a:bg[1]) : ''

    if type(a:attr) != s:NUMBER_TYPE && !(g:spring_night_kill_italic && a:attr ==# 'italic')
        let attr =  'gui=' . a:attr

        if a:attr !=# 'italic'
            let attr .= ' cterm=' . a:attr
        endif
    else
        let attr = ''
    endif

    " XXX: term=NONE is a workaround for unintentional default values
    exe 'hi' a:name 'term=NONE' guifg guibg ctermfg ctermbg attr
endfunction

" Color pallet
let s:black0    = ['#1b1f20', 0]
let s:black1    = ['#2a2f32', 0]
let s:black2    = ['#4e5d62', 0]
let s:blue1     = ['#2d4955', 0]
let s:blue2     = ['#3a6987', 0]
let s:blue3     = ['#88a0ac', 0]
let s:green     = ['#4c6b5c', 0]
let s:red       = ['#d0a998', 0]
let s:white     = ['#fffff3', 0]
let s:none      = ['NONE', 'NONE']

"         Name,             Foreground,     Background, Attribute
call s:hi('Normal',         s:red,          0,          0)
call s:hi('Cursor',         s:red,          0,          0)
call s:hi('CursorLine',     s:red,          0,          0)
call s:hi('CuesorColumn',   s:red,          0,          0)
call s:hi('ColorColumn',    s:red,          0,          0)
call s:hi('LineNr',         s:red,          0,          0)
call s:hi('VerSplit',       s:red,          0,          0)
call s:hi('MatchParen',     s:red,          0,          0)
call s:hi('StatusLine',     s:red,          0,          0)
call s:hi('Pmenu',          s:red,          0,          0)
call s:hi('PmenuSel',    s:red,          0,          0)
call s:hi('IncSearch',    s:red,          0,          0)
call s:hi('Search',    s:red,          0,          0)
call s:hi('Directory',    s:red,          0,          0)
call s:hi('Folded',    s:red,          0,          0)

call s:hi('Boolean',    s:red,          0,          0)
call s:hi('Character',    s:red,          0,          0)
call s:hi('Comment',    s:red,          0,          0)
call s:hi('Conditional',    s:red,          0,          0)
call s:hi('Constant',    s:red,          0,          0)
call s:hi('Define',    s:red,          0,          0)
call s:hi('DiffAdd',    s:red,          0,          0)
call s:hi('DiffDelete',    s:red,          0,          0)
call s:hi('DiffChange',    s:red,          0,          0)
call s:hi('DiffText',    s:red,          0,          0)
call s:hi('ErrorMsg',    s:red,          0,          0)
call s:hi('WarningMsg',    s:red,          0,          0)
call s:hi('Float',    s:red,          0,          0)
call s:hi('Function',    s:red,          0,          0)
call s:hi('Identifier',    s:red,          0,          0)
call s:hi('Keyword',    s:red,          0,          0)
call s:hi('Label',    s:red,          0,          0)
call s:hi('NonText',    s:red,          0,          0)
call s:hi('Number',    s:red,          0,          0)
call s:hi('Operater',    s:red,          0,          0)
call s:hi('PreProc',    s:red,          0,          0)
call s:hi('Special',    s:red,          0,          0)
call s:hi('SpecialKey',    s:red,          0,          0)
call s:hi('Statement',    s:red,          0,          0)
call s:hi('StorageClass',    s:red,          0,          0)
call s:hi('String',    s:red,          0,          0)
call s:hi('Tag',    s:red,          0,          0)
call s:hi('Title',    s:red,          0,          0)
call s:hi('Todo',    s:red,          0,          0)
call s:hi('Type',    s:red,          0,          0)
call s:hi('Underlined',    s:red,          0,          0)

" Python Highlighting
call s:hi('pythonBuiltinFunc',    s:red,          0,          0)

" Javascript Highlighting
call s:hi('jsBuiltins',    s:red,          0,          0)
call s:hi('jsFunction',    s:red,          0,          0)
call s:hi('jsGlobalObjects',    s:red,          0,          0)
call s:hi('jsAssignmentExps',    s:red,          0,          0)

" Html Highlighting
call s:hi('htmlLink',    s:red,          0,          0)
call s:hi('htmlStatement',    s:red,          0,          0)
call s:hi('htmlSpecialTagName',    s:red,          0,          0)

" Markdown Highlighting
call s:hi('mkdCode',    s:red,          0,          0)


