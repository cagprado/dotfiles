" Vim filetype plugin file
" Language: laTeX

setl tw=0 cc=80

" ft-tex-syntax
let g:tex_conceal = ''
let g:tex_comment_nospell = 1

" vimtex
let g:vimtex_format_enabled = 1
let g:vimtex_syntax_autoload_packages = ['amsmath', 'natbib', 'cleveref', 'asymptote', 'minted']

" vimtex-indent
let g:vimtex_indent_enabled = 1
let g:vimtex_indent_bib_enabled = 1
let g:vimtex_indent_on_ampersands = 0  " breaks manual arrangement of equation parts
let g:vimtex_indent_delims = { 'open': ['[{[]'], 'close': ['[}\]]'] }

" vimtex-fold
let g:vimtex_fold_enabled = 1
let g:vimtex_fold_types = {
\   'sections' : {
\       'parse_levels' : 0,
\       'sections' : [
\           'section',
\           'subsection',
\           'subsubsection',
\       ],
\   },
\   'envs' : {
\       'blacklist' : [
\           'center',
\       ],
\   },
\}

" vimtex + deoplete
call deoplete#custom#var('omni', 'input_patterns', {'tex': g:vimtex#re#deoplete})

" vimtex custom imaps
" punctuation
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '‘', 'rhs': '`'})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '’', 'rhs': ''''})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '„', 'rhs': ',,'})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '“', 'rhs': '``'})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '”', 'rhs': ''''''})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '–', 'rhs': '--'})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '—', 'rhs': '---'})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '…', 'rhs': '\dots '})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '«', 'rhs': '\guillemetleft'})
call vimtex#imaps#add_map({'leader': '', 'wrapper': 'vimtex#imaps#wrap_trivial', 'lhs': '»', 'rhs': '\guillemetright'})

" math symbols
call vimtex#imaps#add_map({'leader': '', 'lhs': '·', 'rhs': '\inner'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '≠', 'rhs': '\neq'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '≤', 'rhs': '\leq'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '≥', 'rhs': '\geq'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ℓ', 'rhs': '\ell'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '÷', 'rhs': '\div'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '¯', 'rhs': '\overline{'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∞', 'rhs': '\infty'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∂', 'rhs': '\dpartial'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∅', 'rhs': '\emptyset'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '±', 'rhs': '\pm'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ħ', 'rhs': '\hbar'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∫', 'rhs': '\int'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '×', 'rhs': '\times'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∇', 'rhs': '\dnabla'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '₀', 'rhs': '_0'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∓', 'rhs': '\mp'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ℵ', 'rhs': '\aleph'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ℜ', 'rhs': '\Re'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ℑ', 'rhs': '\Im'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '†', 'rhs': '^{\dagger}'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Å', 'rhs': '\Angstrom'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '√', 'rhs': '\sqrt'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∑', 'rhs': '\sum'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '∏', 'rhs': '\prod'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '♫', 'rhs': '\twonotes'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '♫', 'rhs': '\twonotes'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁰', 'rhs': '^0'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '¹', 'rhs': '^1'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '²', 'rhs': '^2'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '³', 'rhs': '^3'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁴', 'rhs': '^4'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁵', 'rhs': '^5'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁶', 'rhs': '^6'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁷', 'rhs': '^7'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁸', 'rhs': '^8'})
call vimtex#imaps#add_map({'leader': '', 'lhs': '⁹', 'rhs': '^9'})

" math greek letters
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ω', 'rhs': '\omega'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Ω', 'rhs': '\Omega'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ε', 'rhs': '\varepsilon'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ϵ', 'rhs': '\epsilon'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ρ', 'rhs': '\rho'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'τ', 'rhs': '\tau'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ψ', 'rhs': '\psi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Ψ', 'rhs': '\Psi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'υ', 'rhs': '\upsilon'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Υ', 'rhs': '\Upsilon'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ι', 'rhs': '\iota'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'θ', 'rhs': '\theta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Θ', 'rhs': '\Theta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'π', 'rhs': '\pi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Π', 'rhs': '\Pi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'α', 'rhs': '\alpha'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'σ', 'rhs': '\sigma'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Σ', 'rhs': '\Sigma'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'δ', 'rhs': '\delta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Δ', 'rhs': '\Delta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'φ', 'rhs': '\varphi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ϕ', 'rhs': '\phi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Φ', 'rhs': '\Phi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'γ', 'rhs': '\gamma'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Γ', 'rhs': '\Gamma'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'κ', 'rhs': '\kappa'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'λ', 'rhs': '\lambda'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Λ', 'rhs': '\Lambda'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ζ', 'rhs': '\zeta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'χ', 'rhs': '\chi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ξ', 'rhs': '\xi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'Ξ', 'rhs': '\Xi'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'ν', 'rhs': '\nu'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'β', 'rhs': '\beta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'η', 'rhs': '\eta'})
call vimtex#imaps#add_map({'leader': '', 'lhs': 'μ', 'rhs': '\mu'})
