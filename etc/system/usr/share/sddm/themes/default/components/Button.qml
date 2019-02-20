import QtQuick 2.11
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import "."

FocusScope { id: root
    // interface
    signal activate
    property real size
    property string text
    property alias icon: icon.source
    property alias altIcon: icon.alternativeSource
    property bool keep_focus: false
    implicitWidth: layout.width
    implicitHeight: layout.height
    activeFocusOnTab: true
    enabled: key_mouse.active
    onActiveFocusChanged: activeFocus || (focus = false)

    // layout
    ColumnLayout { id: layout
        spacing: 0

        Icon { id: icon
            size: 3*root.size
            Layout.alignment: Qt.AlignHCenter
        }

        Loader { id: label
            active: root.text != ""
            sourceComponent: label_component
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // interaction
    Loader { id: key_mouse
        active: true
        anchors.fill: parent
        sourceComponent: key_mouse_component
    }

    // dynamic components
    Component { id: label_component
        Text {
            text: root.text
            font.pixelSize: root.size
            font.bold: true
        }
    }

    Component { id: key_mouse_component
        MouseArea {
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate()
            onEntered: root.focus = true
            onExited: keep_focus || (root.focus = false)
            readonly property bool active: root.focus

            Glow {
                source: icon
                anchors.horizontalCenter: parent.horizontalCenter
                width: icon.size
                height: icon.size
                samples: 23
                cached: true
                opacity: parent.active && 1 || 0
                Behavior on opacity { NumberAnimation { duration: 200 }}
            }
        }
    }
    Keys.onEnterPressed: { event.accepted = true; activate(); }
    Keys.onReturnPressed: { event.accepted = true; activate(); }
    Keys.onSpacePressed: { event.accepted = true; activate(); }
}
