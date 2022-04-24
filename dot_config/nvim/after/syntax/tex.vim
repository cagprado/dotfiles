" Vim syntax file
" Language:	TeX

syn match texCmdMath     "\\ce\>"    nextgroup=texMathZoneEnsured
syn match texCmdItem     "\\item\>"  conceal cchar=●
syn match texTabularChar "\\\\"      conceal cchar=↲
