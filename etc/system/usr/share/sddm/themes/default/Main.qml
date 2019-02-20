import QtQuick 2.11
import "components"

FocusScope { id: window
    focus: true
    Configuration { id: theme }

    Background { id: wallpaper }
    //GlassLayer { id: glass_layer }

    Clock {
        size: theme.scale
        anchors.top: window.top
        anchors.right: window.right
        anchors.margins: 0.15*window.height
    }

    Login {
        size: 1.2*theme.scale
        anchors.centerIn: window
    }

    PowerMenu {
        size: 0.7*theme.scale
        anchors.bottom: window.bottom
        anchors.left: window.left
        anchors.bottomMargin: 0.05*window.height
    }
}
