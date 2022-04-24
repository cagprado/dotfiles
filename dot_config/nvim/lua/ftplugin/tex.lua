local g = vim.g
vim.bo.tw = 0

-- ft-tex-syntax
g.tex_conceal = 'abdmgs'
g.tex_comment_nospell = true
g.vimtex_syntax_conceal_cites = {type='icon', icon=' '}

-- vimtex + deoplete
vim.cmd 'let g:vimtex#re#deoplete'
vim.fn['deoplete#custom#var'](
  'omni', 'input_patterns', {tex=g['vimtex#re#deoplete']}
)

-- vimtex
g.vimtex_format_enabled = true
g.vimtex_syntax_packages = {
  amsmath   = {load = 2},
  asymptote = {load = 2},
  cleverref = {load = 2},
  minted    = {load = 2},
  natbib    = {load = 2},
}

-- vimtex-indent
g.vimtex_indent_enabled = true
g.vimtex_indent_bib_enabled = true
g.vimtex_indent_on_ampersands = false
g.vimtex_indent_delims = {open={'[{[]'}, close={'[}\\]]'}}

-- vimtex-fold
vim.wo.fdm = 'expr'
vim.wo.fde = 'vimtex#fold#level(v:lnum)'
vim.wo.fdt = 'v:lua.tex_foldtext()'

g.vimtex_fold_types = {
  envs = {blacklist={'center'}},
  sections = {
    parse_levels = 0,
    sections = {
      'section',
      'subsection',
      'subsubsection',
    },
  },
  cmd_single = {
    cmds = {
      'slide',
      'frame',
      'hypersetup',
      'sisetup',
      'tikzset',
      'pgfplotstableread',
      'lstset',
    },
  },
}

tex_foldtext_types = {
  preamble       = function(line)
    return "[Preamble]"
  end,
  cmd_single     = function(line)
    return line
  end,
  cmd_single_opt = function(line)
    return line
  end,
  cmd_multi      = function(line)
    return line
  end,
  cmd_addplot    = function(line)
    return line
  end,
  sections       = function(line)
    return '• Section'
  end,
  markers        = function(line)
    return line
  end,
  comments       = function(line)
    return line
  end,
  items          = function(line)
    return line
  end,
  envs           = function(line)
    return line
  end,
  env_options    = function(line)
    return line
  end,
  default        = function(line)
    return 'default'
  end
}

function tex_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)

  for _, type in ipairs(vim.b.vimtex.fold_types_ordered) do
    --vim.cmd('lo
    --if vim.fn.match(line, type.re.start) == 0 then
    --  return tex_foldtext_types[type.name](line)
    --end
  end

  return tex_foldtext_types.default(line)
end

-- vimtex custom imaps
vim.cmd[[fu! __imap_wrap(lhs, rhs) abort
  return vimtex#syntax#in_comment() ? a:lhs : a:rhs
endfunction]]

function imap_add(lhs, rhs)
  vim.fn['vimtex#imaps#add_map']({
    leader='', lhs=lhs, rhs=rhs, wrapper='__imap_wrap',
  })
end

-- punctuation
imap_add('‘',  [[`]])               imap_add('’',  [[']])
imap_add('“',  [[``]])              imap_add('”',  [['']])
imap_add('„',  [[,,]])              imap_add('…',  [[\dots]])
imap_add('–',  [[--]])              imap_add('—',  [[---]])
imap_add('«',  [[\guillemetleft]])  imap_add('»',  [[\guillemetright]])

-- math symbols
imap_add('≠',  [[\neq]])            imap_add('√',  [[\sqrt]])
imap_add('≤',  [[\leq]])            imap_add('≥',  [[\geq]])
imap_add('¯',  [[\overline{]])      imap_add('†',  [[^{\dagger}]])
imap_add('∅',  [[\emptyset]])       imap_add('∞',  [[\infty]])
imap_add('±',  [[\pm]])             imap_add('∓',  [[\mp]])
imap_add('∫',  [[\int]])            imap_add('·',  [[\inner]])
imap_add('×',  [[\times]])          imap_add('÷',  [[\div]])
imap_add('∂',  [[\dpartial]])       imap_add('∇',  [[\dnabla]])
imap_add('ℜ',  [[\Re]])             imap_add('ℑ',  [[\Im]])
imap_add('Å',  [[\Angstrom]])       imap_add('ℓ',  [[\ell]])
imap_add('ℵ',  [[\aleph]])          imap_add('ħ',  [[\hbar]])
imap_add('∑',  [[\sum]])            imap_add('∏',  [[\prod]])
imap_add('⁰',  [[^0]])              imap_add('₀',  [[_0]])
imap_add('¹',  [[^1]])              imap_add('₁',  [[_1]])
imap_add('²',  [[^2]])              imap_add('₂',  [[_2]])
imap_add('³',  [[^3]])              imap_add('₃',  [[_3]])
imap_add('⁴',  [[^4]])              imap_add('₄',  [[_4]])
imap_add('⁵',  [[^5]])              imap_add('₅',  [[_5]])
imap_add('⁶',  [[^6]])              imap_add('₆',  [[_6]])
imap_add('⁷',  [[^7]])              imap_add('₇',  [[_7]])
imap_add('⁸',  [[^8]])              imap_add('₈',  [[_8]])
imap_add('⁹',  [[^9]])              imap_add('₉',  [[_9]])
imap_add('⁻',  [[^-]])              imap_add('₋',  [[_-]])
imap_add('⁺',  [[^+]])              imap_add('₊',  [[_+]])
imap_add('⁼',  [[^=]])              imap_add('₌',  [[_=]])
imap_add('♫',  [[\twonotes]])

-- greek letters
imap_add('ω',  [[\omega]])          imap_add('Ω',  [[\Omega]])
imap_add('ε',  [[\varepsilon]])     imap_add('ϵ',  [[\epsilon]])
imap_add('ρ',  [[\rho]])            imap_add('τ',  [[\tau]])
imap_add('ψ',  [[\psi]])            imap_add('Ψ',  [[\Psi]])
imap_add('υ',  [[\upsilon]])        imap_add('Υ',  [[\Upsilon]])
imap_add('ι',  [[\iota]])
imap_add('θ',  [[\theta]])          imap_add('Θ',  [[\Theta]])
imap_add('π',  [[\pi]])             imap_add('Π',  [[\Pi]])
imap_add('α',  [[\alpha]])
imap_add('σ',  [[\sigma]])          imap_add('Σ',  [[\Sigma]])
imap_add('δ',  [[\delta]])          imap_add('Δ',  [[\Delta]])
imap_add('φ',  [[\varphi]])
imap_add('ϕ',  [[\phi]])            imap_add('Φ',  [[\Phi]])
imap_add('γ',  [[\gamma]])          imap_add('Γ',  [[\Gamma]])
imap_add('κ',  [[\kappa]])
imap_add('λ',  [[\lambda]])         imap_add('Λ',  [[\Lambda]])
imap_add('ζ',  [[\zeta]])
imap_add('χ',  [[\chi]])
imap_add('ξ',  [[\xi]])             imap_add('Ξ',  [[\Xi]])
imap_add('ν',  [[\nu]])
imap_add('β',  [[\beta]])
imap_add('η',  [[\eta]])
imap_add('μ',  [[\mu]])
