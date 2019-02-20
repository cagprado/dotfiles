import QtQuick 2.11
import QtQuick.Layouts 1.11
import "."

FocusScope { id: root
    property real size
    property bool show: false
    property bool lock: false
    width: menu.width + height
    height: menu.height
    enabled: visible
    visible: buttons.count > 0

    ItemBackground { anchors.fill: item }

    MouseArea { id: item
        width: parent.width + 0.5*height  // hide border when animating
        height: parent.height
        hoverEnabled: true

        x: show && -height || 0.5*height - width
        Behavior on x { NumberAnimation { id: animation
            duration: 500
            easing.type: Easing.InOutBack
        }}

        onClicked: !lock && (show = !show)
        onEntered: !lock && (show = true)
        onExited:  !lock && (show = false)

        // buttons of menu
        RowLayout { id: menu
            x: height
            spacing: 0
            Repeater { model: PowerMenuModel { id: buttons
                delegate: Button {
                    Layout.margins: size
                    size: root.size
                    text: model.text()
                    icon: "../assets/" + model.icon
                    onActivate: model.action()
                    enabled: !animation.running
                }
            }}
        }
    }

    // signals to add buttons as they become available
    Connections {
        target: sddm
        onCanSuspendChanged: buttons.update()
        onCanHybridSleepChanged: buttons.update()
        onCanHibernateChanged: buttons.update()
        onCanRebootChanged: buttons.update()
        onCanPowerOffChanged: buttons.update()
    }

    // interaction
    onActiveFocusChanged: show = activeFocus
    Keys.onEscapePressed: { show = false; event.accepted = false; }
    onShowChanged: (lock = true) && !show && (focus = false)
    Timer {
        // short lock to deal with mixed signals when using touch-screen
        interval: 100
        running: lock
        onTriggered: lock = false
    }
}
