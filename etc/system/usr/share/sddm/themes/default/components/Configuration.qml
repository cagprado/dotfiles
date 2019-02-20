import QtQuick 2.11
import SddmComponents 2.0

QtObject {
    readonly property TextConstants text: TextConstants { }

    readonly property real scale:            0.02*window.height*(config.scale || 1)
    readonly property real shadow_offset:    0.1*scale
    readonly property url wallpaper:         path(config.wallpaper) || "../assets/wallpaper.jpg"
    readonly property string typeface:       config.typeface        || "sans-serif"
    readonly property color text_color:      config.text_color      || "white"
    readonly property color selection_color: config.selection_color || "#3e999f"
    readonly property color warning_color:   config.warning_color   || "#eab700"
    readonly property color error_color:     config.error_color     || "#c82829"
    readonly property color glass_color:     config.glass_color     || "#4271ae"
    readonly property color shadow_color:    config.shadow_color    || "black"
    readonly property bool show_last_user:   is_true(config.show_last_user)

    // fix relative path so it's relative to theme root path (not the components)
    function path(p) { return (p && p.charAt(0) != "/") ? ("../" + p) : p }

    // test if value is true or false for different syntax
    function is_true(x) { return x && x == 1 || x == 'true' || x == 'True' || x == 'TRUE' }

    // list of some session names so we can find icons for them
    property var session_list: [ "awesome", "cinnamon", "gnome", "i3", "kde", "plasma" ]

    function get_session_name(name) {
        for (var i in session_list) {
            var index = name.toLowerCase().indexOf(session_list[i])
            if (index >= 0)
                return session_list[i]
        }
        return "unknown"
    }
}
