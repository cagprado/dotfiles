--• API shortcuts                                                    {{{1
-- define some common aliases
g, w, b, t, v = vim.g, vim.w, vim.b, vim.t, vim.v
ex   = vim.cmd
env  = vim.env
call = vim.fn
setg = vim.o
setb = vim.bo
setw = vim.wo

-- search for scope defined global-local variables
function opt(name)
  function get(dict)
    success, value = pcall(function() return dict[name] end)
    return success and value or nil
  end
  return get(vim.bo) or get(vim.wo) or get(vim.o)
end

-- shortcut for defining key maps
function map(mode, lhs, rhs, opts)
  vim.api.nvim_set_keymap(mode, lhs, rhs,
    vim.tbl_extend('force', {noremap=true, silent=true}, opts or {})
  )
end

-- shortcut for defining autocommands
function au(event, filter, command)
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
    return 1
  end
end
au('BufReadPost', '*', 'lua restore_cursor()')

--• searching very magic                                                 {{{1
map('', '/', [[/\v]], {silent=false})

--• spell cycle                                                          {{{1
local languages = {'', 'en_us', 'pt_br'}
function cycle_spell()
  if not b.slang then b.slang = 0 end
  b.slang = (b.slang + 1) % #languages

  command = b.slang == 0 and 'setlocal no' or 'setlocal '
  ex(command..'spell spelllang='..languages[1+b.slang])
end
map('' , '<F12>',      ':lua cycle_spell()<CR>')
map('!', '<F12>', '<C-O>:lua cycle_spell()<CR>')

-- vim: fdm=marker
