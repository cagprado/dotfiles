" vi:syntax=vim

" Modified for personal taste from base16-tomorrow
" base16-vim (https://github.com/chriskempson/base16-vim)
" by Chris Kempson (http://chriskempson.com)
" Tomorrow scheme by Chris Kempson (http://chriskempson.com)

" GUI color definitions
let s:gui00 = "#fafafa"
let s:gui01 = "#e0e0e0"
let s:gui02 = "#d6d6d6"
let s:gui03 = "#8e908c"
let s:gui04 = "#969896"
let s:gui05 = "#4d4d4c"
let s:gui06 = "#282a2e"
let s:gui07 = "#1d1f21"
let s:gui08 = "#c82829"
let s:gui09 = "#f5871f"
let s:gui0A = "#eab700"
let s:gui0B = "#718c00"
let s:gui0C = "#3e999f"
let s:gui0D = "#4271ae"
let s:gui0E = "#8959a8"
let s:gui0F = "#a3685a"

" Terminal color definitions
let s:cterm00 = "07"
let s:cterm01 = "07"
let s:cterm02 = "07"
let s:cterm03 = "15"
let s:cterm04 = "15"
let s:cterm05 = "00"
let s:cterm06 = "08"
let s:cterm07 = "08"
let s:cterm08 = "01"
let s:cterm09 = "03"
let s:cterm0A = "11"
let s:cterm0B = "02"
let s:cterm0C = "06"
let s:cterm0D = "04"
let s:cterm0E = "05"
let s:cterm0F = "01"

" Theme setup
hi clear
syntax reset
let g:colors_name = "base16-tomorrow"

" Highlighting function
fun <sid>hi(group, guifg, guibg, ctermfg, ctermbg, guiattr, attr, guisp)
  exec "hi" a:group "guifg=" a:guifg "guibg=" a:guibg "ctermfg=" a:ctermfg "ctermbg=" a:ctermbg "gui=" a:guiattr "cterm=" a:attr "guisp=" a:guisp
endfun

" Vim editor colors
call <sid>hi("Bold",          "NONE", "NONE", "NONE", "NONE", "BOLD", "NONE", "NONE")
call <sid>hi("Debug",         s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Directory",     s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Error",         s:gui00, s:gui08, s:cterm00, s:cterm08, "NONE", "NONE", "NONE")
call <sid>hi("ErrorMsg",      s:gui08, s:gui00, s:cterm08, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("Exception",     s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("FoldColumn",    s:gui0C, s:gui01, s:cterm0C, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("Folded",        s:gui03, s:gui01, s:cterm03, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("IncSearch",     s:gui01, s:gui09, s:cterm01, s:cterm09, "NONE", "NONE", "NONE")
call <sid>hi("Italic",        "NONE", "NONE", "NONE", "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Macro",         s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("MatchParen",    "NONE", s:gui03, "NONE", s:cterm03,  "NONE", "NONE", "NONE")
call <sid>hi("ModeMsg",       s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("MoreMsg",       s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Question",      s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Search",        s:gui03, s:gui0A, s:cterm03, s:cterm0A,  "NONE", "NONE", "NONE")
call <sid>hi("Substitute",    s:gui03, s:gui0A, s:cterm03, s:cterm0A, "NONE", "NONE", "NONE")
call <sid>hi("SpecialKey",    s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("TooLong",       s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Underlined",    s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Visual",        "NONE", s:gui02, "NONE", s:cterm02, "NONE", "REVERSE", "NONE")
call <sid>hi("VisualNOS",     s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("WarningMsg",    s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("WildMenu",      s:gui08, s:gui0A, s:cterm08, s:cterm0A, "NONE", "NONE", "NONE")
call <sid>hi("Title",         s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Conceal",       s:gui0D, s:gui00, s:cterm0D, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("Cursor",        s:gui00, s:gui05, s:cterm00, s:cterm05, "NONE", "NONE", "NONE")
call <sid>hi("NonText",       s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Normal",        s:gui05, s:gui00, s:cterm05, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("LineNr",        s:gui03, s:gui01, s:cterm03, s:cterm05, "NONE", "NONE", "NONE")
call <sid>hi("SignColumn",    s:gui03, s:gui01, s:cterm03, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("StatusLine",    s:gui04, s:gui02, s:cterm04, s:cterm02, "NONE", "NONE", "NONE")
call <sid>hi("StatusLineNC",  s:gui03, s:gui01, s:cterm03, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("VertSplit",     s:gui02, s:gui02, s:cterm02, s:cterm02, "NONE", "NONE", "NONE")
call <sid>hi("ColorColumn",   "NONE", s:gui01, s:cterm03, s:cterm05, "NONE", "NONE", "NONE")
call <sid>hi("CursorColumn",  "NONE", s:gui01, "NONE", s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("CursorLine",    "NONE", s:gui01, "NONE", "NONE", "NONE", "BOLD", "NONE")
call <sid>hi("CursorLineNr",  s:gui04, s:gui01, s:cterm00, s:cterm05, "NONE", "NONE", "NONE")
call <sid>hi("QuickFixLine",  "NONE", s:gui01, "NONE", s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("PMenu",         s:gui04, s:gui01, s:cterm04, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("PMenuSel",      s:gui01, s:gui04, s:cterm01, s:cterm05, "NONE", "NONE", "NONE")
call <sid>hi("TabLine",       s:gui03, s:gui01, s:cterm03, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("TabLineFill",   s:gui03, s:gui01, s:cterm03, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("TabLineSel",    s:gui0B, s:gui01, s:cterm0B, s:cterm01, "NONE", "NONE", "NONE")

" Standard syntax highlighting
call <sid>hi("Boolean",      s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Character",    s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Comment",      s:gui03, "NONE", s:cterm03, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("Conditional",  s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Constant",     s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Define",       s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Delimiter",    s:gui0F, "NONE", s:cterm0F, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Float",        s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Function",     s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Identifier",   s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Include",      s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Keyword",      s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Label",        s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Number",       s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Operator",     s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("PreProc",      s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Repeat",       s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Special",      s:gui0C, "NONE", s:cterm0C, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("SpecialChar",  s:gui0F, "NONE", s:cterm0F, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Statement",    s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StorageClass", s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("String",       s:gui0B, "NONE", s:cterm0B, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("Structure",    s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Tag",          s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Todo",         s:gui0A, s:gui01, s:cterm0A, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("Type",         s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("Typedef",      s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")

" C highlighting
call <sid>hi("cOperator",   s:gui0C, "NONE", s:cterm0C, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("cPreCondit",  s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")

" C# highlighting
call <sid>hi("csClass",                 s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("csAttribute",             s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("csModifier",              s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("csType",                  s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("csUnspecifiedStatement",  s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("csContextualStatement",   s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("csNewDecleration",        s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")

" CSS highlighting
call <sid>hi("cssBraces",      s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("cssClassName",   s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("cssColor",       s:gui0C, "NONE", s:cterm0C, "NONE", "NONE", "NONE", "NONE")

" Diff highlighting
call <sid>hi("DiffAdd",      s:gui0B, s:gui01,  s:cterm0B, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("DiffChange",   s:gui03, s:gui01,  s:cterm03, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("DiffDelete",   s:gui08, s:gui01,  s:cterm08, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("DiffText",     s:gui0D, s:gui01,  s:cterm0D, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("DiffAdded",    s:gui0B, s:gui00,  s:cterm0B, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("DiffFile",     s:gui08, s:gui00,  s:cterm08, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("DiffNewFile",  s:gui0B, s:gui00,  s:cterm0B, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("DiffLine",     s:gui0D, s:gui00,  s:cterm0D, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("DiffRemoved",  s:gui08, s:gui00,  s:cterm08, s:cterm00, "NONE", "NONE", "NONE")

" Git highlighting
call <sid>hi("gitcommitOverflow",       s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitSummary",        s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitComment",        s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitUntracked",      s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitDiscarded",      s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitSelected",       s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitHeader",         s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitSelectedType",   s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitUnmergedType",   s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitDiscardedType",  s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitBranch",         s:gui09, "NONE", s:cterm09, "NONE", "BOLD", "BOLD", "NONE")
call <sid>hi("gitcommitUntrackedFile",  s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("gitcommitUnmergedFile",   s:gui08, "NONE", s:cterm08, "NONE", "BOLD", "BOLD", "NONE")
call <sid>hi("gitcommitDiscardedFile",  s:gui08, "NONE", s:cterm08, "NONE", "BOLD", "BOLD", "NONE")
call <sid>hi("gitcommitSelectedFile",   s:gui0B, "NONE", s:cterm0B, "NONE", "BOLD", "BOLD", "NONE")

" GitGutter highlighting
call <sid>hi("GitGutterAdd",     s:gui0B, s:gui01, s:cterm0B, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("GitGutterChange",  s:gui0D, s:gui01, s:cterm0D, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("GitGutterDelete",  s:gui08, s:gui01, s:cterm08, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("GitGutterChangeDelete",  s:gui0E, s:gui01, s:cterm0E, s:cterm01, "NONE", "NONE", "NONE")

" HTML highlighting
call <sid>hi("htmlBold",    s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("htmlItalic",  s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("htmlEndTag",  s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("htmlTag",     s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")

" JavaScript highlighting
call <sid>hi("javaScript",        s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("javaScriptBraces",  s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("javaScriptNumber",  s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
" pangloss/vim-javascript highlighting
call <sid>hi("jsOperator",          s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsStatement",         s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsReturn",            s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsThis",              s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsClassDefinition",   s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsFunction",          s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsFuncName",          s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsFuncCall",          s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsClassFuncName",     s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsClassMethodType",   s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsRegexpString",      s:gui0C, "NONE", s:cterm0C, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsGlobalObjects",     s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsGlobalNodeObjects", s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsExceptions",        s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("jsBuiltins",          s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")

" Mail highlighting
call <sid>hi("mailQuoted1",  s:gui0A, "NONE", s:cterm0A, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("mailQuoted2",  s:gui0B, "NONE", s:cterm0B, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("mailQuoted3",  s:gui0E, "NONE", s:cterm0E, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("mailQuoted4",  s:gui0C, "NONE", s:cterm0C, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("mailQuoted5",  s:gui0D, "NONE", s:cterm0D, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("mailQuoted6",  s:gui0A, "NONE", s:cterm0A, "NONE", "ITALIC", "NONE", "NONE")
call <sid>hi("mailURL",      s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("mailEmail",    s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")

" Markdown highlighting
call <sid>hi("markdownCode",              s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("markdownError",             s:gui05, s:gui00, s:cterm05, s:cterm00, "NONE", "NONE", "NONE")
call <sid>hi("markdownCodeBlock",         s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("markdownHeadingDelimiter",  s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")

" NERDTree highlighting
call <sid>hi("NERDTreeDirSlash",  s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("NERDTreeExecFile",  s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")

" PHP highlighting
call <sid>hi("phpMemberSelector",  s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("phpComparison",      s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("phpParent",          s:gui05, "NONE", s:cterm05, "NONE", "NONE", "NONE", "NONE")

" Python highlighting
call <sid>hi("pythonOperator",  s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("pythonRepeat",    s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("pythonInclude",   s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("pythonStatement", s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")

" Ruby highlighting
call <sid>hi("rubyAttribute",               s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("rubyConstant",                s:gui0A, "NONE", s:cterm0A, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("rubyInterpolationDelimiter",  s:gui0F, "NONE", s:cterm0F, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("rubyRegexp",                  s:gui0C, "NONE", s:cterm0C, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("rubySymbol",                  s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("rubyStringDelimiter",         s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")

" SASS highlighting
call <sid>hi("sassidChar",     s:gui08, "NONE", s:cterm08, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("sassClassChar",  s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("sassInclude",    s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("sassMixing",     s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("sassMixinName",  s:gui0D, "NONE", s:cterm0D, "NONE", "NONE", "NONE", "NONE")

" Signify highlighting
call <sid>hi("SignifySignAdd",     s:gui0B, s:gui01, s:cterm0B, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("SignifySignChange",  s:gui0D, s:gui01, s:cterm0D, s:cterm01, "NONE", "NONE", "NONE")
call <sid>hi("SignifySignDelete",  s:gui08, s:gui01, s:cterm08, s:cterm01, "NONE", "NONE", "NONE")

" Spelling highlighting
call <sid>hi("SpellBad",     s:gui08, s:gui00, s:cterm08, s:cterm00, "REVERSE", "REVERSE", s:gui08)
call <sid>hi("SpellCap",     s:gui0A, s:gui00, s:cterm0A, s:cterm00, "REVERSE", "REVERSE", s:gui0D)
call <sid>hi("SpellLocal",   s:gui0D, s:gui00, s:cterm0D, s:cterm00, "REVERSE", "REVERSE", s:gui0C)
call <sid>hi("SpellRare",    s:gui0C, s:gui00, s:cterm0C, s:cterm00, "REVERSE", "REVERSE", s:gui0E)

" Startify highlighting
call <sid>hi("StartifyBracket",  s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifyFile",     s:gui07, "NONE", s:cterm07, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifyFooter",   s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifyHeader",   s:gui0B, "NONE", s:cterm0B, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifyNumber",   s:gui09, "NONE", s:cterm09, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifyPath",     s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifySection",  s:gui0E, "NONE", s:cterm0E, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifySelect",   s:gui0C, "NONE", s:cterm0C, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifySlash",    s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")
call <sid>hi("StartifySpecial",  s:gui03, "NONE", s:cterm03, "NONE", "NONE", "NONE", "NONE")

" Airline highlighting
let g:airline#themes#base16_tomorrow#palette = {}

if !&termguicolors
    call airline#parts#define_accent('mode', 'none')
    call airline#parts#define_accent('linenr', 'none')
    call airline#parts#define_accent('maxlinenr', 'none')
endif

let s:N1   = [ s:gui01, s:gui0B, s:cterm01, s:cterm0B ]
let s:N2   = [ s:gui06, s:gui02, s:cterm03, s:cterm05 ]
let s:N3   = [ s:gui09, s:gui01, s:cterm09, s:cterm01 ]
let g:airline#themes#base16_tomorrow#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let s:I1   = [ s:gui01, s:gui0D, s:cterm01, s:cterm0D ]
let s:I2   = [ s:gui06, s:gui02, s:cterm03, s:cterm05 ]
let s:I3   = [ s:gui09, s:gui01, s:cterm09, s:cterm01 ]
let g:airline#themes#base16_tomorrow#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)

let s:R1   = [ s:gui01, s:gui08, s:cterm01, s:cterm08 ]
let s:R2   = [ s:gui06, s:gui02, s:cterm03, s:cterm05 ]
let s:R3   = [ s:gui09, s:gui01, s:cterm09, s:cterm01 ]
let g:airline#themes#base16_tomorrow#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)

let s:V1   = [ s:gui01, s:gui0E, s:cterm01, s:cterm0E ]
let s:V2   = [ s:gui06, s:gui02, s:cterm03, s:cterm05 ]
let s:V3   = [ s:gui09, s:gui01, s:cterm09, s:cterm01 ]
let g:airline#themes#base16_tomorrow#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let s:IA1   = [ s:gui05, s:gui01, s:cterm05, s:cterm01 ]
let s:IA2   = [ s:gui05, s:gui01, s:cterm05, s:cterm01 ]
let s:IA3   = [ s:gui05, s:gui01, s:cterm05, s:cterm01 ]
let g:airline#themes#base16_tomorrow#palette.inactive = airline#themes#generate_color_map(s:IA1, s:IA2, s:IA3)

" Here we define the color map for ctrlp.  We check for the g:loaded_ctrlp
" variable so that related functionality is loaded if the user is using
" ctrlp. Note that this is optional, and if you do not define ctrlp colors
" they will be chosen automatically from the existing palette.
if get(g:, 'loaded_ctrlp', 0)
    let g:airline#themes#base16_tomorrow#palette.ctrlp = airline#extensions#ctrlp#generate_color_map(
        \ [ s:gui07, s:gui02, s:cterm07, s:cterm02, '' ],
        \ [ s:gui07, s:gui04, s:cterm07, s:cterm04, '' ],
        \ [ s:gui05, s:gui01, s:cterm05, s:cterm01, 'bold' ])
endif

" Remove functions and color variables
delf <sid>hi
unlet s:gui00 s:gui01 s:gui02 s:gui03  s:gui04  s:gui05  s:gui06  s:gui07  s:gui08  s:gui09 s:gui0A  s:gui0B  s:gui0C  s:gui0D  s:gui0E  s:gui0F
unlet s:cterm00 s:cterm01 s:cterm02 s:cterm03 s:cterm04 s:cterm05 s:cterm06 s:cterm07 s:cterm08 s:cterm09 s:cterm0A s:cterm0B s:cterm0C s:cterm0D s:cterm0E s:cterm0F
unlet s:N1 s:N2 s:N3 s:I1 s:I2 s:I3 s:R1 s:R2 s:R3 s:V1 s:V2 s:V3 s:IA1 s:IA2 s:IA3
