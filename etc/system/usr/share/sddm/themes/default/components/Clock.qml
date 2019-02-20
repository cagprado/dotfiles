import QtQuick 2.11
import QtQuick.Layouts 1.11
import "."

Item {
    property alias size: date.font.pixelSize
    width: childrenRect.width
    height: childrenRect.height

    DropShadow {
        anchors.fill: clock
        source: clock
    }

    ColumnLayout { id: clock
        Layout.alignment: Qt.AlignHCenter
        spacing: -0.3*week.font.pixelSize

        Text { id: week
            Layout.fillWidth: true
            style: Text.Normal
            font.pixelSize: 1.5*date.font.pixelSize
        }
        RowLayout {
            Text { id: hour
                Layout.fillWidth: true
                textFormat: Text.StyledText
                style: Text.Normal
                font.pixelSize: 3*date.font.pixelSize
            }
            Text { id: secs
                Layout.fillWidth: true
                textFormat: Text.StyledText
                style: Text.Normal
                font.pixelSize: 0.9*date.font.pixelSize
            }
        }
        Text { id: date
            Layout.fillWidth: true
            style: Text.Normal
        }
    }

    // logic
    signal update
    onUpdate: {
        var format = Qt.formatDateTime(new Date(), 'dddd|<b>hh</b>:mm|A<br>ss|MMMM d, yyyy').split('|');
        week.text = format[0]; hour.text = format[1]; secs.text = format[2]; date.text = format[3]
    }

    Component.onCompleted: update()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.update()
    }
}
