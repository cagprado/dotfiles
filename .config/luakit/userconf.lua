local modes = require "modes"
modes.add_binds("normal", {
    { "<Control-Shift-c>", "Copy selected text.", function ()
        luakit.selection.clipboard = luakit.selection.primary
    end},
})

local settings = require "settings"
settings.webview.zoom_level = 120
settings.webview.zoom_text_only = false
settings.webview.enable_smooth_scrolling = true
settings.session.always_save = true
settings.webview.enable_accelerated_2d_canvas = true


local downloads = require "downloads"
downloads.add_signal("download-location", function (uri, file)
    if not file or file == "" then
        file = (string.match(uri, "/([^/]+)$")
            or string.match(uri, "^%w+://(.+)")
            or string.gsub(uri, "/", "_")
            or "untitled")
    end
    return downloads.default_dir .. "/" .. file
end)
