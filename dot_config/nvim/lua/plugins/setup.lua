require('packer').startup({function()
  use {'wbthomason/packer.nvim', opt=true}

  -- convenience
  --use {'lilydjwg/fcitx.vim', branch='fcitx5'}  -- disable IM in normal mode
  use {'ericcurtin/CurtineIncSw.vim',          -- header/source switch    {{{
    config=function()
      vim.api.nvim_set_keymap('', '<F2>', ':call CurtineIncSw()<CR>', {
        noremap=true, silent=true
      })
    end
  } --}}}]]
  use {'liuchengxu/vista.vim',                 -- project structure       {{{
    config=function()
      vim.cmd 'nnoremap <silent> <A-=> :Vista!!<CR>'
      vim.g['vista#renderer#icons'] = {
        ['func']           = '󰊕',
        ['function']       = '󰊕',
        ['functions']      = '󰊕',
        ['var']            = '󰬟',
        ['variable']       = '󰬟',
        ['variables']      = '󰬟',
        ['const']          = '󰐀',
        ['constant']       = '󰐀',
        ['constructor']    = '󱌣',
        ['method']         = '󰆧',
        ['package']        = '󰏗',
        ['packages']       = '󰏗',
        ['enum']           = '',
        ['enummember']     = '󰎤',
        ['enumerator']     = '',
        ['module']         = '󰘙',
        ['modules']        = '󰘙',
        ['type']           = '󰏘',
        ['typedef']        = '󰏘',
        ['types']          = '󰏘',
        ['field']          = '󱓼',
        ['fields']         = '󱓼',
        ['macro']          = '󰐤',
        ['macros']         = '󰐤',
        ['map']            = '󰙅',
        ['class']          = '󰒪',
        ['augroup']        = '󰙅',
        ['struct']         = '󰒪',
        ['union']          = '󰝸',
        ['member']         = '󰌕',
        ['target']         = '󰓾',
        ['property']       = '󰖷',
        ['interface']      = '󰘘',
        ['namespace']      = '󰅩',
        ['subroutine']     = '󰊕',
        ['implementation'] = '󰘦',
        ['typeParameter']  = '󰅴',
        ['default']        = '󱔢',
      }
    end
  } --}}}]]

  -- syntax
  use {'nvim-treesitter/nvim-treesitter',      -- context analysis        {{{
    config=function()
      pcall(function()
        require'nvim-treesitter.configs'.setup {
          --ensure_installed = "maintained",
          ensure_installed = { 'c', 'cpp', 'lua' },
          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },
        }
        vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
      end)
    end,
    run=':TSUpdate'
  } --}}}]]
  use {'p00f/nvim-ts-rainbow',                 -- TS module (rainbow)     {{{
    config=function()
      pcall(function()
        require'nvim-treesitter.configs'.setup {rainbow = {enable = true}}
      end)
    end,
    after='nvim-treesitter'
  } --}}}]]

  use {'neovim/nvim-lspconfig'}
  --[[use {'hoob3rt/lualine.nvim',                 -- lualine status line     {{{
    config=function()
      ---- mode indicators
      --local modes = {
      --  n='SLModeNormal',  c='SLModeCommand', i='SLModeInsert',
      --  R='SLModeReplace', r='SLModeConfirm', t='SLModeConfirm',
      --  ['!'] = 'SLModeConfirm',
      --}

      --local function set_mode()
      --  vim.cmd('hi! link SLMode '
      --    .. (modes[vim.fn.mode():sub(1, 1)] or 'SLModeVisual'))
      --  return '█'
      --end
      --local modeL = {set_mode, color='SLMode', left_padding=0}
      --local modeR = {'"█"',   color='SLMode', right_padding=0}

      -- file size
      local function buffer_not_empty()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
      end

      local function show_fsize()
        local size = vim.fn.getfsize(vim.fn.expand('%:p'))
        local e = math.min(5, math.floor(math.log(size)/math.log(1024)))
        return math.floor(size / math.pow(1024, e))
          ..({'', 'K', 'M', 'G', 'T', 'P'})[e+1]
      end

      -- file format icons
      local function show_fformat()
        return ({unix=' ', dos=' ', mac=' '})[vim.bo.fileformat]
      end

      -- setup lualine
      require('lualine').setup{
        options = {
          theme = 'tomorrow',
          component_separators = {},
          section_separators = {'', ''},
        },

        sections = {
          lualine_a = {{'" "', right_padding=0}},
          lualine_z = {{'" "', right_padding=0}},

          lualine_b = {},
          lualine_y = {},

          lualine_c = {
            {show_fsize, condition=buffer_not_empty, right_padding=0},
            {'filename', condition=buffer_not_empty,
              symbols = {modified='󰀩 ', readonly='󰌾 '}
            },
            {'location', right_padding=0},
            {'progress'},
          },
          lualine_x = {
            {show_fformat, right_padding=0},
            {'o:encoding', upper=true},
            {'branch', icon=' '},
            {'diff',
              symbols = {added='󰐗 ', removed='󰍶 ', modified='󰻂 '},
              --color_added = colors.green,
              --color_modified = colors.orange,
              --color_removed = colors.red,
            },
          }
        }
      }
    end
  } --}}}]]
  use {'Shougo/deoplete.nvim',                 -- completion              {{{
    config=function()
      vim.g['deoplete#enable_at_startup'] = true
      vim.o.completeopt = 'menu,noinsert'

      -- remove the currently typed word from the menu
      pcall(vim.fn['deoplete#custom#source'], '_', 'matchers', {
        'matcher_fuzzy', 'matcher_length'
      })
    end,
    run=':UpdateRemotePlugins'
  } --}}}]]
  use {'tpope/vim-fugitive'}                   -- git interaction
  use {'tpope/vim-surround'}                   -- surrounding moves
  use {'Shougo/neosnippet.vim'}                -- snippets engine
  use {'Shougo/neosnippet-snippets'}           -- snippets library
  use {'lervag/vimtex'}                        -- LaTeX plugin
  use {'python-mode/python-mode'}              -- Python syntax plugin
  use {'fatih/vim-go'}                         -- Go language
  --use {'ludovicchabant/vim-gutentags'}         -- Work with CTags
  use {'romainl/vim-cool'}

  --paq {'shougo/deoplete-lsp'}
  --paq {'neovim/nvim-lspconfig'}
  --paq {'ojroques/nvim-lspfuzzy'}
  --paq {'junegunn/fzf', hook = fn['fzf#install']}
end, config={ compile_path = vim.g.packer }})
