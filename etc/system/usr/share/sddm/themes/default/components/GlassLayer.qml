import QtQuick 2.11
import QtGraphicalEffects 1.0

Component {
    RecursiveBlur {
        //visible: false
        width: wallpaper.width
        height: wallpaper.height
        source: wallpaper
        radius: 8
        loops: 4

        Rectangle {
            anchors.fill: parent
            color: theme.glass_color
            opacity: 0.3
        }
    }
}
