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
    b.cms = '()'..(setb.cms == '' and '^%s' or setb.cms):gsub('%p', '%%%1')
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
-- - interface                                                           {{{2
local sl_conditions = {
  is_active = function()
    return call.win_getid() == tonumber(g.actual_curwin)
  end,
  name_is = function(name)
    return function() return call.expand('%') == name end
  end,
}

local function statusline(...)
  local statusline = {
    {items={}},
    {items={}, condition=sl_conditions.is_active}
  }

  for _, item in ipairs({...}) do
    -- make sure item is a table
    item = type(item) ~= 'table' and {item} or item

    -- items should be functions
    for i = 1, 2 do
      if type(item[i]) == 'string' then
        local text = item[i]
        item[i] = function() return text end
      end
    end

    -- organize items following conditions
    if item.condition then
      local items
      for i = 2, #statusline-1 do
        if statusline[i].condition == item.condition then
          items = statusline[i].items
          break
        end
      end

      if not items then
        table.insert(statusline, 2, {items={}, condition=item.condition})
        items = statusline[2].items
      end

      table.insert(items, item[1])
    else
      if item[1] then
        table.insert(statusline[#statusline].items, item[1])
      end
      if item[2] then
        item[2] = item[2] == true and item[1] or item[2]
        table.insert(statusline[1].items, item[2])
      end
    end
  end

  update_statusline = function()
    local items = statusline[1].items
    for i = 2, #statusline do
      if statusline[i].condition() then
        items = statusline[i].items
        break
      end
    end

    setw.stl = '%{execute("call v:lua.update_statusline()")}'
    for _, item in ipairs(items) do
      setw.stl = setw.stl .. item()
    end
  end
end
setg.statusline = '%{execute("call v:lua.update_statusline()")}'

-- - helper functions                                                    {{{2
local function sl_highlight(name)
  return name and ('%#'..name..'#') or '%*'
end

local function sl_mode_color()
  ex('hi! link SLMode ' .. (({
    c = 'SLModeCommand',     i = 'SLModeInsert',      n = 'SLModeNormal',
    R = 'SLModeReplace',     r = 'SLModeConfirm',     t = 'SLModeConfirm',
    v = 'SLModeVisual',  ['!'] = 'SLModeConfirm'
  }) [call.mode():sub(1, 1)] or 'SLModeVisual'))
  return sl_highlight('SLMode')
end

local function sl_filesize()
  local size = call.getfsize(call.expand('%:p'))
  if size <= 0 then return (' '):rep(6) end
  local e = math.min(5, math.floor(math.log(size)/math.log(1024)))
  return ('%5s '):format(math.floor(size / math.pow(1024, e))
    ..({'', 'K', 'M', 'G', 'T', 'P'})[e+1])
end

local function sl_filename()
  local info = (setb.filetype == 'help' and not setb.modifiable)
    and ('['..call.expand('%:t:r')..']') or call.expand('%:~:.')

  -- encoding
  if setb.fenc:len() > 0 and setb.fenc ~= 'utf-8' then
    info = info .. (' [%s]'):format(setb.fenc)
  end

  local width = math.max(1, math.floor(0.5*call.winwidth(0)) - 16)
  return ('%%.%d(%s%%)'):format(width, call.printf('%-'..width..'S', info))
end

local function sl_location()
  local l1 = call.line('w0')
  local l2 = call.line('w$')
  local nl = call.line('$')
  local wd = math.max(7, math.floor(0.5 + 32 * (l2-l1+1) / nl))
  local rate = math.floor((32-wd) * l1 / (nl+l1-l2-1))
  nl = (32 - wd - rate) / 8

  local p = (' '):rep(rate / 8)
  rate = math.floor(rate % 8)

  if rate > 0 then
    p = p .. ({'🮋','🮊','🮉','▐','🮈','🮇','▕'})[rate]
    wd = wd - (8-rate)
  end

  p = p .. ('█'):rep(wd / 8)
  rate = math.floor(wd % 8)

  if rate > 0 then
    p = p .. ({'▏','▎','▍','▌','▋','▊','▉'})[rate]
  end

  p = p .. (' '):rep(nl)

  return '%4l %#SLRuler#'..p..'%* %-4v'
end

local function sl_flags()
  local flags = {}

  -- modification status
  if setb.ro or not setb.ma then
    flags[#flags+1] = setb.mod and '󰏮 ' or '󰌾 '
  elseif setb.mod then
    flags[#flags+1] = '󰏫 '
  end

  -- file format
  local format = ({dos=' ', mac=' ', unix=''})[setb.ff]
  if format then
    flags[#flags+1] = format
  end

  -- filetype
  flags[#flags+1] = ({
    -- mdi-languages
    c                 = '󰙱 ',
    cpp               = '󰙲 ',
    cs                = '󰌛 ',
    css               = '󰌜 ',
    fortran           = '󱈚 ',
    go                = '󰟓 ',
    haskell           = '󰲒 ',
    html              = '󰌝 ',
    java              = '󰬷 ',
    javascript        = '󰌞 ',
    kotlin            = '󱈙 ',
    lua               = '󰢱 ',
    markdown          = '󰍔 ',
    php               = '󰌟 ',
    python            = '󰌠 ',
    r                 = '󰟔 ',
    ruby              = '󰴭 ',
    swift             = '󰛥 ',
    typescript        = '󰛦 ',
    -- others
    asy               = '󰄪 ',
    datafile          = '󰣟 ',
    diff              = '󰢪 ',
    gitcommit         = '󰊢 ',
    help              = '󰋗 ',
    sh                = ' ',
    tex               = '󱓷 ',
    text              = '󰧭 ',
    vim               = ' ',
    zsh               = ' ',
  })[setb.ft] or setb.ft

  -- spell check
  if setw.spell then
    flags[#flags+1] = ('%s󰓆 '):format(({pt_br = '󰫽', en_us = '󰫲'})[setb.spl])
  end

  return table.concat(flags)
end

-- - items                                                               {{{2
statusline(
  sl_mode_color,
  {'█ ',           '█       '},
  sl_highlight,
  sl_filesize,
  {sl_filename,     true},
  sl_location,
  {'%=',            true},
  {sl_flags,        true},
  --'branch', 'diff',
  sl_mode_color(),
  {' █',           true},

  {function()
    return sl_conditions.is_active()
      and (sl_mode_color() .. ('█'):rep(call.winwidth(0)))
      or ''
  end, condition=sl_conditions.name_is('[packer]')}
)

-- vim: fdm=marker
