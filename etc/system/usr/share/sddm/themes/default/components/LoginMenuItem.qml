import QtQuick 2.6
import QtQuick.Layouts 1.1
import "."

MouseArea { id: root
    property alias text: text.text
    property alias icon: icon.source
    property alias altIcon: icon.alternativeSource
    property bool highlight: false
    readonly property ListView list: ListView.view
    readonly property real size: list.parent.size

    implicitWidth: item.width
    implicitHeight: item.height
    width: list.width
    hoverEnabled: true

    signal activated
    onClicked: activated()
    onEntered: { list.currentIndex = index }
    onImplicitWidthChanged: { list.parent.item_width = Math.max(list.parent.item_width, implicitWidth); }
    onImplicitHeightChanged: { list.parent.item_height = implicitHeight; }

    LoginMenuHighlight {
        anchors.fill: parent
        color: theme.selection_color
        visible: parent.highlight
    }

    RowLayout { id: item
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

        Icon { id: icon
            Layout.margins: 0.2*size
            size: 1.5*root.size
        }

        Text { id: text
            Layout.margins: 0.2*size
            font.pixelSize: Math.max(1, size)
            horizontalAlignment: Text.AlignLeft
        }
    }
}
