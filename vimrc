
"---------------------------------------------------------------------------
" 基本設定的な : {{{
"
" 文字コードをUTF-8に設定
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
" 編集時の文字コードをUTF-8に設定
set encoding=utf-8
" vim script 内で使用するエンコーディング設定
scriptencoding utf-8
" vi 互換モードでうごくな
set nocompatible
" 背景の感じを決める (たぶんカラースキーマによっては意味ない)
set background=dark
" カラースキーマを変更
colorscheme elflord
" モードラインをON
set modeline
" ファイルタイプごとのいろいろをON
filetype off
filetype plugin indent on
filetype on


"---------------------------------------------------------------------------
" 検索の挙動に関する設定 : {{{
"
" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase
" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase
" 検索文字列入力時に順次検索対象文字列にヒットさせる
set incsearch
" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set nowrapscan
" 検索語をハイライト表示
set hlsearch
" }}}


"---------------------------------------------------------------------------
" 編集に関する設定 : {{{
"
" タブの画面上での幅
set tabstop=4
" 自動インデントでずれる幅
set shiftwidth=4
" 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set softtabstop=4
" タブをスペースに展開しない (expandtab or noexpandtab)
set expandtab
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
" 改行時に前の行の構文をチェックし次の行のインデントを増減する
set smartindent
" バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" いくつかのモードで文字のないところにカーソルが移動できるようになる
set virtualedit=block
" クリップボード連携
set clipboard+=unnamed,autoselect
" ウィンドウ上下にカーソルが移動したときに，カーソル先の視界をどれだけ確保するか (べつにウィンドウ外に出ても機能するわけじゃない)
set scrolloff=4
" }}}


"---------------------------------------------------------------------------
" 画面表示の設定 : {{{
"
" シンタックスハイライトを有効に
syntax enable
" 行番号を非表示 (number:表示)
set number
" ルーラーを表示 (noruler:非表示)
set ruler
" タブや改行を表示 (tabは->，半角スペースは.)
set list listchars=tab:»\ ,trail:·,eol:¬
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap
" 自動改行もいんでんと 
if (v:version == 704 && has("patch785")) || v:version >= 705
    set breakindent
endif
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set cmdheight=2
" コマンドをステータス行に表示
set showcmd
" タイトルを表示
set title
" 現在の行を強調表示
set cursorline
" ビープ音を可視化
set visualbell
" 256色使えるようにする
set t_Co=256
" 画面を黒地に白にする (次行の先頭の " を削除すれば有効になる)
colorscheme hybrid
" 24色にする
if v:version >= 800
    set termguicolors
endif
" 行番号の色
highlight LineNr ctermfg=white
" カーソルラインの色
highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=black
" }}}

"---------------------------------------------------------------------------
" ファイル操作に関する設定 : {{{
"
" バックアップファイルを作成しない (次行の先頭の " を削除すれば有効になる)
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" }}}


"---------------------------------------------------------------------------
" マッピング : {{{
"
" 折り返し時に表示行単位での移動を可能に
nnoremap j gj
nnoremap k gk

" 括弧の補完
inoremap { {}<Left>
inoremap {<CR> {}<Left><CR><CR><UP><TAB>
inoremap <expr> } BracketThrough('}')
inoremap [ []<Left>
inoremap <expr> ] BracketThrough(']')
inoremap ( ()<Left>
inoremap <expr> ) BracketThrough(')')
inoremap <expr> " BracketThrough('"')
inoremap <expr> ' BracketThrough("'")
" inoremap < <><Left>
inoremap <expr> > BracketThrough('>')

" ヴィジュアルモードでインデントいじってまたヴィジュアルモードになる
vnoremap > >gv
vnoremap < <gv

" Shiftとhやlで行頭，行末にそれぞれ移動
noremap <S-h> ^
noremap <S-l> $

" PP でヤンクレジスタから貼り付ける
" noremap p "0p

" ターミナルをウィンドウで上下左右に開く
command! Lterm lefta vert term
command! Rterm rightb vert term
command! Tterm abo term
command! Bterm bel term
command! Lmterm topleft vert term
command! Rmterm botright vert term
command! Tmterm topleft term
command! Bmterm botright term


"---------------------------------------------------------------------------
" プラグイン関連
"


"---------------------------------------------------------------------------
" 折りたたみ表示の設定
"
" 折りたたみを構文依存に
set foldmethod=syntax
" 折りたたみの色
highlight Folded ctermfg=none ctermbg=none
" 折りたたみのガイドの色 (なんなんこれ)
highlight FoldedColumn ctermfg=darkgray ctermbg=white
" fold の fill 文字をケシてるらしい
set fillchars=vert:\|


"---------------------------------------------------------------------------
" 閉じ括弧等の入力受け流し : {{{
function! BracketThrough(hoge)
	if getline('.')[col('.')-1] == a:hoge
		return "\<Right>"
	endif
	return a:hoge
endfunction
" }}}


" カーソル行のurlをデフォルのブラウザで開く : {{{
" http://d.hatena.ne.jp/shunsuk/20110508/1304865150
function! HandleURI()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
  echo s:uri
  if s:uri != ""
    exec "!xdg-open \"" . s:uri . "\""
  else
    echo "No URI found in line."
  endif
endfunction
" \w でurlを開く
map <Leader>w :call HandleURI()<CR>
" }}}


"---------------------------------------------------------------------------
" 全角スペースの可視化 : {{{
" http://inari.hatenablog.com/entry/2014/05/05/231307
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme * call ZenkakuSpace()
        autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
    augroup END
    call ZenkakuSpace()
endif
" }}}


"---------------------------------------------------------------------------
" 挿入モード時、ステータスラインの色を変更 : {{{
" https://sites.google.com/site/fudist/Home/vim-nihongo-ban/-vimrc-sample
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction
" }}}


"---------------------------------------------------------------------------
" :AutoUpdateColorscheme でカラースキームを3秒毎に更新
" https://rhysd.hatenablog.com/entry/2016/12/17/191158
function! s:auto_update_colorscheme(...) abort
    if &ft !=# 'vim'
        echoerr 'Execute this command in colorscheme file buffer'
    endif
    setlocal autoread noswapfile
    let interval = a:0 > 0 ? a:1 : 3000
    let timer = timer_start(interval, {-> execute('checktime')}, {'repeat' : -1})
    autocmd! BufReadPost <buffer> source %
endfunction
command! -nargs=? AutoUpdateColorscheme call <SID>auto_update_colorscheme(<f-args>)

