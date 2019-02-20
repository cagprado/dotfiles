import QtQuick 2.11
import QtQuick.Controls 2.4

TextField {
    property real size
    readonly property bool alert_capslock: activeFocus && keyboard.capsLock

    width: 15*size
    echoMode: TextInput.Password
    font.family: theme.typeface
    font.pixelSize: size
    color: theme.shadow_color
    horizontalAlignment: TextInput.AlignHCenter
    focus: true

    Text {
        // workaround for placeholderText does not appear when centering (bug?)
        anchors.centerIn: parent
        text: theme.text.password
        font.pixelSize: parent.font.pixelSize
        font.capitalization: alert_capslock && Font.AllUppercase || Font.MixedCase
        visible: !parent.text
        color: Qt.rgba(0.3*(theme.shadow_color.r + theme.text_color.r), 0.3*(theme.shadow_color.g + theme.text_color.g), 0.3*(theme.shadow_color.b + theme.text_color.b), 1)
    }

    background: Rectangle {
        color: alert_capslock && theme.warning_color || theme.text_color
        opacity: 0.8
        radius: 0.3*height
    }

    Connections { target: sddm
        onLoginFailed: {
            selectAll()
            forceActiveFocus()
        }
    }

    signal reset
    onReset: text = ""
    onAccepted: request_login(text)
    Keys.onEscapePressed: login.select(0)

    Connections {
        // on multi-head setup, clear password field when moving to another screen
        target: window
        onActiveFocusChanged: reset()
    }
}
