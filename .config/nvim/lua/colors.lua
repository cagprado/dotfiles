-- Based on base16-tomorrow (https://github.com/chriskempson/base16-vim)
-- Base16 syntax highlighting guidelines:
-- • base00: Default Background
-- • base01: Lighter Background (status bars, line number and folding marks)
-- • base02: Selection Background
-- • base03: Comments, Invisibles, Line Highlighting
-- • base04: Dark Foreground (Used for status bars)
-- • base05: Default Foreground, Caret, Delimiters, Operators
-- • base06: Light Foreground (Not often used)
-- • base07: Light Background (Not often used)
-- • base08: Variables, XML Tags, Markup Link Text and Lists, Diff Deleted
-- • base09: Integers, Boolean, Constants, XML Attributes, Markup Link Url
-- • base0A: Classes, Markup Bold, Search Text Background
-- • base0B: Strings, Inherited Class, Markup Code, Diff Inserted
-- • base0C: Support, Regular Expressions, Escape Characters, Markup Quotes
-- • base0D: Functions, Methods, Attribute IDs, Headings
-- • base0E: Keywords, Storage, Selector, Markup Italic, Diff Changed
-- • base0F: Deprecated, Opening/Closing Embedded Language Tags: <?php ?>

local function setup(attributes)
  vim.cmd 'hi clear'
  vim.cmd 'syntax reset'
  vim.g.colors_name = 'default'

  local hi = 'hi %s guifg=%s guibg=%s gui=%s guisp=%s'
    ..' ctermfg=%s ctermbg=%s cterm=%s'

  for group, values in pairs(attributes) do
    vim.cmd(hi:format(group, values[1][1], values[2][1], values[3][1],
      values[4][1], values[1][2], values[2][2], values[3][2]))
  end
end

-- aliases
local no     = {'NONE',             'NONE'         }
local bf     = {'bold',             'bold'         }
local ul     = {'underline',        'NONE'         }
local uc     = {'undercurl',        'NONE'         }
local rv     = {'reverse',          'reverse'      }
local it     = {'italic',           'NONE'         }
local ri     = {'reverse,italic',   'reverse'      }
local b0, b8 = {'#fafafa', '07'},  {'#c82829', '01'}
local b1, b9 = {'#efefef', '00'},  {'#f5871f', '03'}
local b2, bA = {'#d6d6d6', '00'},  {'#eab700', '11'}
local b3, bB = {'#8e908c', '15'},  {'#718c00', '02'}
local b4, bC = {'#a6a8a6', '15'},  {'#3e999f', '06'}
local b5, bD = {'#4d4d4c', '00'},  {'#4271ae', '04'}
local b6, bE = {'#282a2e', '07'},  {'#8959a8', '05'}
local b7, bF = {'#1d1f21', '07'},  {'#a3685a', '01'}

setup{
  -- Editor colors
  Bold                       = {no, no, bf, no},
  Debug                      = {b8, no, no, no},
  Directory                  = {bD, no, no, no},
  Error                      = {b0, b8, no, no},
  ErrorMsg                   = {b8, b0, no, no},
  Exception                  = {b8, no, no, no},
  FoldColumn                 = {b3, b1, no, no},
  Folded                     = {b0, b4, ri, no},
  IncSearch                  = {b1, b9, no, no},
  Italic                     = {no, no, it, no},
  Macro                      = {b8, no, no, no},
  MatchParen                 = {no, b3, no, no},
  ModeMsg                    = {bB, no, no, no},
  MoreMsg                    = {bB, no, no, no},
  Question                   = {bD, no, no, no},
  Search                     = {b3, bA, no, no},
  Substitute                 = {b3, bA, no, no},
  SpecialKey                 = {b3, no, no, no},
  TooLong                    = {b8, no, no, no},
  Underlined                 = {no, no, ul, no},
  Visual                     = {no, b2, no, no},
  VisualNOS                  = {b8, no, no, no},
  WarningMsg                 = {b8, no, no, no},
  WildMenu                   = {b1, b5, no, no},
  Title                      = {bD, no, no, no},
  Conceal                    = {bD, b0, no, no},
  Cursor                     = {b0, b5, no, no},
  NonText                    = {b3, no, no, no},
  Normal                     = {b5, b0, no, no},
  LineNr                     = {b3, b1, no, no},
  SignColumn                 = {b3, b1, no, no},
  StatusLine                 = {b5, b2, no, no},
  StatusLineNC               = {b4, b2, no, no},
  VertSplit                  = {b1, b1, no, no},
  ColorColumn                = {b0, b8, rv, no},
  CursorColumn               = {no, b1, no, no},
  CursorLine                 = {no, b1, no, no},
  CursorLineNr               = {b3, b1, no, no},
  QuickFixLine               = {no, b1, no, no},
  PMenu                      = {b5, b2, no, no},
  PMenuSel                   = {b1, b5, no, no},
  PMenuSbar                  = {b2, no, no, no},
  PMenuThumb                 = {b2, b5, no, no},
  TabLine                    = {b3, b1, no, no},
  TabLineFill                = {b3, b1, no, no},
  TabLineSel                 = {bB, b1, no, no},
  -- Standard syntax highlighting
  Boolean                    = {b9, no, no, no},
  Character                  = {b8, no, no, no},
  Comment                    = {b3, no, it, no},
  Conditional                = {bE, no, no, no},
  Constant                   = {b9, no, no, no},
  Define                     = {bE, no, no, no},
  Delimiter                  = {bF, no, no, no},
  Float                      = {b9, no, no, no},
  Function                   = {bD, no, no, no},
  Identifier                 = {b8, no, no, no},
  Include                    = {bD, no, no, no},
  Keyword                    = {bE, no, no, no},
  Label                      = {bA, no, no, no},
  Number                     = {b9, no, no, no},
  Operator                   = {b5, no, no, no},
  PreProc                    = {bA, no, no, no},
  Repeat                     = {bA, no, no, no},
  Special                    = {bC, no, no, no},
  SpecialChar                = {bF, no, no, no},
  Statement                  = {b8, no, no, no},
  StorageClass               = {bA, no, no, no},
  String                     = {bB, no, it, no},
  Structure                  = {bE, no, no, no},
  Tag                        = {bA, no, no, no},
  Todo                       = {bA, b1, no, no},
  Type                       = {bA, no, no, no},
  Typedef                    = {bA, no, no, no},
  -- C language
  cOperator                  = {bC, no, no, no},
  cPreCondit                 = {bE, no, no, no},
  -- C#
  csClass                    = {bA, no, no, no},
  csAttribute                = {bA, no, no, no},
  csModifier                 = {bE, no, no, no},
  csType                     = {b8, no, no, no},
  csUnspecifiedStatement     = {bD, no, no, no},
  csContextualStatement      = {bE, no, no, no},
  csNewDecleration           = {b8, no, no, no},
  -- CSS
  cssBraces                  = {b5, no, no, no},
  cssClassName               = {bE, no, no, no},
  cssColor                   = {bC, no, no, no},
  -- Diff
  --DiffAdd                    = {no, b2, bf, no},
  --DiffChange                 = {no, b2, no, no},
  --DiffDelete                 = {b2, b2, no, no},
  --DiffText                   = {b7, b2, bf, no},
  DiffAdd                    = {b0, bD, no, no},
  DiffChange                 = {b0, bA, no, no},
  DiffDelete                 = {b1, b1, no, no},
  DiffText                   = {b8, bA, bf, no},
  -- Git
  gitcommitOverflow          = {b8, no, no, no},
  gitcommitSummary           = {bB, no, no, no},
  gitcommitComment           = {b3, no, no, no},
  gitcommitUntracked         = {b3, no, no, no},
  gitcommitDiscarded         = {b3, no, no, no},
  gitcommitSelected          = {b3, no, no, no},
  gitcommitHeader            = {bE, no, no, no},
  gitcommitSelectedType      = {bD, no, no, no},
  gitcommitUnmergedType      = {bD, no, no, no},
  gitcommitDiscardedType     = {bD, no, no, no},
  gitcommitBranch            = {b9, no, bf, no},
  gitcommitUntrackedFile     = {bA, no, no, no},
  gitcommitUnmergedFile      = {b8, no, bf, no},
  gitcommitDiscardedFile     = {b8, no, bf, no},
  gitcommitSelectedFile      = {bB, no, bf, no},
  -- GitGutter
  GitGutterAdd               = {bB, b1, no, no},
  GitGutterChange            = {bD, b1, no, no},
  GitGutterDelete            = {b8, b1, no, no},
  GitGutterChangeDelete      = {bE, b1, no, no},
  -- HTML
  htmlBold                   = {bA, no, no, no},
  htmlItalic                 = {bE, no, no, no},
  htmlEndTag                 = {b5, no, no, no},
  htmlTag                    = {b5, no, no, no},
  -- JavaScript
  javaScript                 = {b5, no, no, no},
  javaScriptBraces           = {b5, no, no, no},
  javaScriptNumber           = {b9, no, no, no},
  -- pangloss/vim-javascript
  jsOperator                 = {bD, no, no, no},
  jsStatement                = {bE, no, no, no},
  jsReturn                   = {bE, no, no, no},
  jsThis                     = {b8, no, no, no},
  jsClassDefinition          = {bA, no, no, no},
  jsFunction                 = {bE, no, no, no},
  jsFuncName                 = {bD, no, no, no},
  jsFuncCall                 = {bD, no, no, no},
  jsClassFuncName            = {bD, no, no, no},
  jsClassMethodType          = {bE, no, no, no},
  jsRegexpString             = {bC, no, no, no},
  jsGlobalObjects            = {bA, no, no, no},
  jsGlobalNodeObjects        = {bA, no, no, no},
  jsExceptions               = {bA, no, no, no},
  jsBuiltins                 = {bA, no, no, no},
  -- Mail
  mailQuoted1                = {bA, no, no, no},
  mailQuoted2                = {bB, no, no, no},
  mailQuoted3                = {bE, no, no, no},
  mailQuoted4                = {bC, no, no, no},
  mailQuoted5                = {bD, no, no, no},
  mailQuoted6                = {bA, no, no, no},
  mailURL                    = {bD, no, no, no},
  mailEmail                  = {bD, no, no, no},
  -- Markdown
  markdownCode               = {bB, no, no, no},
  markdownError              = {b5, b0, no, no},
  markdownCodeBlock          = {bB, no, no, no},
  markdownHeadingDelimiter   = {bD, no, no, no},
  -- NERDTree
  NERDTreeDirSlash           = {bD, no, no, no},
  NERDTreeExecFile           = {b5, no, no, no},
  -- PHP
  phpMemberSelector          = {b5, no, no, no},
  phpComparison              = {b5, no, no, no},
  phpParent                  = {b5, no, no, no},
  -- Python
  pythonOperator             = {bE, no, no, no},
  pythonRepeat               = {bE, no, no, no},
  pythonInclude              = {bE, no, no, no},
  pythonStatement            = {bE, no, no, no},
  -- Ruby
  rubyAttribute              = {bD, no, no, no},
  rubyConstant               = {bA, no, no, no},
  rubyInterpolationDelimiter = {bF, no, no, no},
  rubyRegexp                 = {bC, no, no, no},
  rubySymbol                 = {bB, no, no, no},
  rubyStringDelimiter        = {bB, no, no, no},
  -- SASS
  sassidChar                 = {b8, no, no, no},
  sassClassChar              = {b9, no, no, no},
  sassInclude                = {bE, no, no, no},
  sassMixing                 = {bE, no, no, no},
  sassMixinName              = {bD, no, no, no},
  -- Signify
  SignifySignAdd             = {bB, b1, no, no},
  SignifySignChange          = {bD, b1, no, no},
  SignifySignDelete          = {b8, b1, no, no},
  -- Spelling
  SpellBad                   = {no, no, uc, b8},
  SpellCap                   = {no, no, uc, bA},
  SpellLocal                 = {no, no, uc, bD},
  SpellRare                  = {no, no, uc, bC},
  -- Startify
  StartifyBracket            = {b3, no, no, no},
  StartifyFile               = {b7, no, no, no},
  StartifyFooter             = {b3, no, no, no},
  StartifyHeader             = {bB, no, no, no},
  StartifyNumber             = {b9, no, no, no},
  StartifyPath               = {b3, no, no, no},
  StartifySection            = {bE, no, no, no},
  StartifySelect             = {bC, no, no, no},
  StartifySlash              = {b3, no, no, no},
  StartifySpecial            = {b3, no, no, no},
  -- Status line
  SLModeNormal               = {bB, b2, no, no},
  SLModeCommand              = {bC, b2, no, no},
  SLModeInsert               = {bD, b2, no, no},
  SLModeReplace              = {b9, b2, no, no},
  SLModeVisual               = {bE, b2, no, no},
  SLModeConfirm              = {b8, b2, no, no},
  SLDelimiter                = {b2, no, no, no},
  SLRuler                    = {b4, b1, no, no},
}

---- airline
--local function fgbg(fg, bg)
--  return {fg[1], bg[1], fg[2], bg[2]}
--end
--
--local function generate(fg, bg)
--  local a, b, c = fgbg(fg[1], bg[1]), fgbg(fg[2], bg[2]), fgbg(fg[3], bg[3])
--  return {
--    airline_a = a, airline_z = a,
--    airline_b = b, airline_y = b,
--    airline_c = c, airline_x = c,
--  }
--end
--
--local function mod_warning(t)
--  return vim.tbl_extend('force', t, {airline_warning = fgbg(b0, b9)})
--end
--
--vim.g['airline#themes#'..vim.g.airline_theme..'#palette'] = {
--  normal      = mod_warning(generate({b0, b7, b5}, {bB, bA, b2})),
--  commandline = mod_warning(generate({b0, b7, b5}, {bC, bA, b2})),
--  insert      = mod_warning(generate({b0, b7, b5}, {bD, bA, b2})),
--  replace     = mod_warning(generate({b0, b7, b5}, {b9, bA, b2})),
--  visual      = mod_warning(generate({b0, b7, b5}, {bE, bA, b2})),
--  inactive    = mod_warning(generate({b3, b3, b3}, {b2, b2, b2})),
--}

