--• API shortcuts                                                    {{{1
-- define some common aliases
local g, w, b, t, v = vim.g, vim.w, vim.b, vim.t, vim.v
local ex   = vim.cmd
local env  = vim.env
local call = vim.fn
local setg = vim.o
local setb = vim.bo
local setw = vim.wo

-- search for scope defined global-local variables
local function opt(name)
  function get(dict)
    success, value = pcall(function() return dict[name] end)
    return success and value or nil
  end
  return get(vim.bo) or get(vim.wo) or get(vim.o)
end

-- shortcut for keymaps
local function map(mode, lhs, rhs, opts)
  vim.api.nvim_set_keymap(mode, lhs, rhs,
    vim.tbl_extend('force', {noremap=true, silent=true}, opts or {})
  )
end

-- shortcut for autocommands
local function au(event, filter, command)
  ex('autocmd UserGroup '..event..' '..filter..' '..command)
end

--• cursorline                                                           {{{1
au('WinEnter,WinEnter,BufWinEnter', '*', 'setl cursorline')
au('WinLeave',                      '*', 'setl nocursorline')

--• folds                                                                {{{1
function foldtext()
  -- check commentstring definition
  if not b.cms then
    b.cms = '()'..setb.cms:gsub('%p', '%%%1')
      :gsub('%%%%s$', '().*()')
      :gsub('%%%%s',  '().-()')
      ..'%s*()'
  end

  -- get fold lines
  local line = call.getline(v.foldstart)
  local last = call.getline(v.foldend)

  -- store last comment in line
  local n, comment
  for l, i, j, r in line:gmatch(b.cms) do
    if r > line:len() then
      -- remove fold markers
      comment = line:sub(i, j-1)
      for marker in setw.fmr:gmatch('[^,]+') do
        comment = comment:gsub('%s*'..marker:gsub('%p', '%%%1')..'%d*', '')
      end

      -- store position and comment
      if call.trim(comment):len() > 0 then
        n = call.charidx(line, l)
        if n == 1 then
          comment = (' '):rep(i-l)..comment
          last = ''
        else
          comment = line:sub(l, i-1)..comment..line:sub(j, r-1)
        end
      end
    end
  end

  -- remove comments
  line = line:gsub(b.cms, ''):gsub('%s*$', '')
  last = last:gsub(b.cms, ''):gsub('%s*$', '')

  -- if same indent, concat with last line
  if line:match('^%s*') == last:match('^%s*') then
    last = call.trim(last)
    if last ~= '' then
      line = line..' … '..call.trim(last)
    end
  end

  -- if there's stored comment
  if n then
    -- add last comment back keeping it's original position
    local len = call.strchars(line)
    if n > 2 and len > n-2 then
      line = call.strcharpart(line, 0, n-3)..'… '
    else
      line = line..(' '):rep(n-len-1)
    end
    line = line..comment
  end

  -- get number of lines in the fold
  local nlines = ('%4dℓ'):format(v.foldend - v.foldstart + 1)

  -- right align number of lines considering textwidth and fillchars
  if setb.tw > 0 then
    n = math.max(0, setb.tw - call.strwidth(nlines))
    line = call.printf('%-.*S', n, line)
      ..(opt('fcs'):match('fold:(.[^,]*)') or '·'):rep(n-call.strwidth(line))
  end

  return line..nlines..'▏'
end
setw.foldtext='v:lua.foldtext()'

--• format paragraph                                                     {{{1
map('n', 'Q', 'gqap')
map('v', 'Q', 'gq')

--• highlight on yank                                                    {{{1
au('TextYankPost', '*', 'lua vim.highlight.on_yank {on_visual = false}')

--• make                                                                 {{{1
map('' , '<F9>',      ':w|:make!<CR>')
map('!', '<F9>', '<C-O>:w|:make!<CR>')

--• movements                                                            {{{1
-- quick window navigation
map('', '<C-H>', '<C-W>h')
map('', '<C-J>', '<C-W>j')
map('', '<C-K>', '<C-W>k')
map('', '<C-L>', '<C-W>l')

-- wrapped lines behave as multiple lines
--map('', 'j', '"gj"', {expr=true})
--map('', 'k', '"gk"', {expr=true})
--map('', '0', '"g0"', {expr=true})
--map('', '^', '"g^"', {expr=true})
--map('', '$', '"g$"', {expr=true})

--• restore cursor                                                       {{{1
function restore_cursor()
  if call.line([['"]]) <= call.line('$') then
    ex 'normal! g`"'
  end
end
au('BufReadPost', '*', 'lua restore_cursor()')

--• searching very magic                                                 {{{1
map('', '/', [[/\v]], {silent=false})

--• spell cycle                                                          {{{1
local languages = {'', 'en_us', 'pt_br'}
function cycle_spell()
  b.slang = (b.slang or 1) % #languages + 1
  setb.spl = languages[b.slang]
  setw.spell = setb.spl:len() > 0
end
map('' , '<F12>',      ':lua cycle_spell()<CR>')
map('!', '<F12>', '<C-O>:lua cycle_spell()<CR>')

--• status line                                                          {{{1
-- - helper functions                                                    {{{2
setg.statusline = '%{execute("call v:lua.update_statusline()")}'

local function sl_normalize(items, normal_hl)
  if not items then return {} end
  normal_hl = normal_hl or 'StatusLine'

  for k, v in pairs(items) do
    v = (type(v) == 'table') and {unpack(v)} or {v}

    if type(v[1]) ~= 'function' then
      local text = v[1]
      v[1] = function() return text end
    end
    v[2] = '%#' .. (v[2] or normal_hl) .. '#'

    items[k] = v
  end

  return items
end

local function statusline(active, inactive, specials)
  local statusline = {}
  for _, special in ipairs(specials or {}) do
    table.insert(statusline, {
      items     = sl_normalize({unpack(special, 2)}),
      condition = special[1]
    })
  end

  table.insert(statusline, {
    items     = sl_normalize(active),
    condition = function()
      return call.win_getid() == tonumber(g.actual_curwin)
    end
  })

  table.insert(statusline, {
    items     = sl_normalize(inactive, 'StatusLineNC'),
    condition = function() return true end
  })

  update_statusline = function()
    local items
    for _, type in ipairs(statusline) do
      if type.condition() then
        items = type.items
        break
      end
    end

    setw.stl = setg.stl
    for _, item in ipairs(items) do
      setw.stl = setw.stl .. item[2] .. item[1]() .. '%*'
    end
  end
end

local sl_mode_colors = {
  n = 'SLModeNormal',       c = 'SLModeCommand',  i = 'SLModeInsert',
  R = 'SLModeReplace',      r = 'SLModeConfirm',  t = 'SLModeConfirm',
  ['!'] = 'SLModeConfirm',  v = 'SLModeVisual',
}

local function sl_mode_set()
  local hl = sl_mode_colors[call.mode():sub(1, 1)] or sl_mode_colors.v
  ex('hi! link SLMode '..hl)
end

local function mod8w(x)
  local integer, fraction = math.modf(3.875*x)
  return integer, math.floor(8*fraction)
end

-- - items                                                               {{{2
local sl_sep   = '%='
local sl_lmode = function() sl_mode_set() return '█ ' end
local sl_rmode = ' █'

local function sl_filesize()
  local size = call.getfsize(call.expand('%:p'))
  if size <= 0 then return (' '):rep(6) end
  local e = math.min(5, math.floor(math.log(size)/math.log(1024)))
  return ('%5s '):format(math.floor(size / math.pow(1024, e))
    ..({'', 'K', 'M', 'G', 'T', 'P'})[e+1])
end

local function sl_filename()
  local info
  if setb.filetype == 'help' and not setb.modifiable then
    info = call.expand('%:t:r') .. ' 󰋗 '
  else
    info = call.expand('%:~:.')
    if info:len() > 0 then
      local flags = (setb.ro or not setb.ma)
        and (setb.mod and '󰏮 ' or '󰌾 ')
        or  (setb.mod and '󰏫 ' or '')
        ..  ({dos=' ', mac=' ', unix=''})[setb.ff]
      if flags:len() > 0 then
        info = info .. ' ' .. flags
      end
    end
  end

  local width = math.max(1, math.floor(0.5*call.winwidth(0)) - 16)
  return ('%%.%d(%s%%)'):format(width, call.printf('%-'..width..'S', info))
end

local bar = {
  {'▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'},
  {'█', '🮋', '🮊', '🮉', '▐', '🮈', '🮇', '▕'}
}

local function sl_location()
  local l1, l2, last = call.line('w0'), call.line('w$'), call.line('$')
  local rate = l2/last
  local step = math.max(0.125/3, (l2-l1)/last)

  local fill, part = mod8w(math.max(0, rate-step))
  local p = (' '):rep(fill) .. bar[2][part+1]

  local tmp = fill
  fill, part = mod8w(rate)
  p = p .. bar[1][8]:rep(fill-tmp) .. bar[1][part+1] .. (' '):rep(3-fill)

  return '%4l %#SLRuler#' .. p .. '%* %-4v'
end

local function sl_spellcheck()
  return setw.spell and ('󰓆  [%s] '):format(setb.spl:sub(1, 2)) or ''
end

statusline({
  -- active
  {sl_lmode, 'SLMode'},
  sl_filesize, sl_filename, sl_location, sl_sep, sl_spellcheck,
  --'branch', 'diff',
  {sl_rmode, 'SLMode'}
},
  -- inactive
  {sl_lmode, (' '):rep(6), sl_filename, sl_sep, sl_rmode}
)


-- vim: fdm=marker
