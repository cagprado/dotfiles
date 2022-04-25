#!/usr/bin/env lua

local projector = '\000\255\255\255\255\255\255\000\054\116\048\000\001\000'
                ..'\000\000\010\022\001\003\128\115\065\120\010\207\116\163'
                ..'\087\076\176\035\009\072\076\033\008\000\129\128\069\064'
                ..'\097\064\149\000\001\001\001\001\001\001\001\001\002\058'
                ..'\128\024\113\056\045\064\088\044\069\000\196\142\033\000'
                ..'\000\030\102\033\080\176\081\000\027\048\000\112\038\068'
                ..'\196\142\033\000\000\030\000\000\000\252\000\084\086\010'
                ..'\032\032\032\032\032\032\032\032\032\032\000\000\000\253'
                ..'\000\050\075\030\080\023\000\010\032\032\032\032\032\032'
                ..'\001\223\002\003\037\242\077\001\003\004\005\007\144\018'
                ..'\019\020\022\159\032\034\038\009\007\007\017\023\080\131'
                ..'\001\000\000\103\003\012\000\016\000\184\045\140\010\208'
                ..'\138\032\224\045\016\016\062\150\000\196\142\033\000\000'
                ..'\024\140\010\208\144\032\064\049\032\012\064\085\000\196'
                ..'\142\033\000\000\025\001\029\000\188\082\208\030\032\184'
                ..'\040\085\064\196\142\033\000\000\031\001\029\128\208\114'
                ..'\028\022\032\016\044\037\128\196\142\033\000\000\159\000'
                ..'\000\000\000\000\000\000\000\000\000\000\000\000\000\000'
                ..'\000\000\000\073'

local find = io.popen('find /sys/class/drm/card0/ -name edid')
local list = find:read('*a')
find:close()

for filename in list:gmatch('%S+') do
  local file = io.open(filename)
  local edid = file:read('*a')
  file:close()

  if edid == projector then
    found = true
    break
  end
end

if found then
  local filter = false
  local sub_name = os.tmpname()

  function setup_sub()
    local sid = tonumber((mp.get_property('sid')))
    if sid then
      local filename   = mp.get_property('path')
      local ffmpeg_cmd = 'ffmpeg -loglevel -8 -y -i "%s" -map 0:s:%d -f ass %s'
      local sub_style  = '' -- ':force_style="PrimaryColour=&HCCFF0000"'
      filter = true

      -- extract ass file using ffmpeg
      os.execute(string.format(ffmpeg_cmd, filename, sid-1, sub_name))

      -- apply subtitles filter then add other video filters for projection
      mp.command('vf set @subs:subtitles=' .. sub_name .. sub_style)
      mp.command('apply-profile projector')
    elseif filter then
      mp.command('vf remove @subs')
      filter = false
    end
  end

  mp.observe_property('sid', 'number', setup_sub)
  mp.register_event('end-file', function() os.remove(sub_name) end)
end
