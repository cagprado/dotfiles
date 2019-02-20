import QtQuick 2.11
import QtQuick.Layouts 1.11

Item { id: root
    property real size

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    RowLayout {
        spacing: 0.5*size
        FocusScope {
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            Button {
                size: root.size
                icon: "../assets/session.svgz"
                onActivate: forceActiveFocus(), session_show(-1)
                keep_focus: parent.activeFocus
                onActiveFocusChanged: activeFocus || session_show(false)
                Keys.forwardTo: [ session ]
            }
        }
        FocusScope {
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            Button {
                size: root.size
                icon: "../assets/keyboard.svgz"
                onActivate: forceActiveFocus(), keyboard_show(-1)
                keep_focus: parent.activeFocus
                onActiveFocusChanged: activeFocus || keyboard_show(false)
                Keys.forwardTo: [ kbdmenu ]
            }
        }
    }
}
