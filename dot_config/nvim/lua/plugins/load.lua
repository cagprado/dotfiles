local packer = require 'packer'

-- compile plugin initialization file if it doesn't exist
vim.cmd('au User PackerComplete if !filereadable("'..vim.g.packer
  ..'") | execute "PackerCompile" | endif')

-- cleanup and install missing plugins
packer.clean()
packer.install()

-- check if at least one plugin needs updating (once a day)
-- NOTE: it only checks git based packages (TODO: improve)
local today = math.floor(os.time()/86400)*86400
local plugins_path = vim.fn.stdpath('data')..'/site/pack/packer/'
local plugins = vim.fn.globpath(plugins_path, '*/*')

local updating = {}
for plugin in string.gmatch(plugins, '([^/]+/[^/\n]+)\n') do
  local filename = plugins_path..plugin..'/.git/FETCH_HEAD'
  if vim.fn.getftime(filename) < today then
    table.insert(updating, string.match(plugin, '[^/]+$'))
  end
end

-- updates outdated plugins
if next(updating) then
  packer.update(unpack(updating))
end
