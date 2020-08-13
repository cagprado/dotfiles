local settings = require "settings"
settings.session.always_save = true
settings.webview.zoom_level = 120
settings.webview.zoom_text_only = false
settings.webview.enable_smooth_scrolling = true
settings.webview.enable_accelerated_2d_canvas = true
settings.window.home_page = "https://www.yandex.com"

local newtab_chrome = require "newtab_chrome"
newtab_chrome.new_tab_src = "<html><head><meta http-equiv='refresh' content=\"0; url='https://www.yandex.com'\" /></head></html>"

local engines = settings.window.search_engines
engines.yandex = "https://yandex.com/search/?text=%s"
engines.baidu  = "https://www.baidu.com/s?wd=%s"
engines.bing   = "https://www.bing.com/search?q=%s"

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

local modes = require "modes"
modes.add_binds("normal", {
    { "<Control-Shift-c>", "Copy selected text.", function ()
        luakit.selection.clipboard = luakit.selection.primary
    end},
})
