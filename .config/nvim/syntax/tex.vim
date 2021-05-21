" Vim syntax file
" Language:	TeX

syntax match texCmdMath     "\\ce\>"    nextgroup=texMathZoneEnsured
syntax match texCmdItem     "\\item\>"  conceal cchar=●
syntax match texTabularChar "\\\\"      conceal cchar=󰌑 
