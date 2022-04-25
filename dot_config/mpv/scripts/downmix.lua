#!/usr/bin/env lua

-- read from pulseaudio the number of channels on the main sink
local pulse_cmd = 'pactl list sinks short | grep $(pactl get-default-sink)'
local process   = io.popen(pulse_cmd)
local channels  = tonumber(process:read('l'):match(' (%d+)ch '))
process:close()


if channels == 4 then
  local downmixing = false
  local function set_downmix(event)
    -- read from file how many sound channels we need
    local nch = tonumber((mp.get_property('audio-params/channel-count')))

    -- set downmix filter
    if nch == 6 then
      downmixing = true
      mp.command('af add @downmix:pan="quad'
                 ..'|FL=0.5*FC+0.707*BL+0.5*LFE'
                 ..'|FR=0.5*FC+0.707*BR+0.5*LFE'
                 ..'|BL=0.5*FC+0.707*FL+0.5*LFE'
                 ..'|BR=0.5*FC+0.707*FR+0.5*LFE"')
    elseif downmixing then
      mp.command('af remove @downmix')
      downmixing = false
    end
  end

  mp.register_event('file-loaded', set_downmix)
end
