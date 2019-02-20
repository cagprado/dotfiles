import QtQuick 2.11
import QtGraphicalEffects 1.0
import "."

Item { id: root
    property alias radius: area.radius
    property bool highlight: false
    property bool alert: false

    Item { id: border
        visible: false
        anchors.centerIn: parent
        width: parent.width + 100
        height: parent.height + 100
        Rectangle { id: area
            anchors.centerIn: parent
            width: parent.parent.width
            height: parent.parent.height
            radius: 0.5*height
        }
    }

    Item { id: effects
        visible: false
        anchors.fill: border
        Glow {
            anchors.fill: parent
            source: border
            color: theme.text_color
            samples: 80
            opacity: highlight && 1 || 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        Glow {
            anchors.fill: parent
            source: border
            color: theme.text_color
            samples: 20
        }
        DropShadow {
            anchors.fill: parent
            source: border
        }
    }

    OpacityMask {
        anchors.fill: border
        maskSource: border
        source: effects
        invert: true
    }

    Rectangle { id: glass
        anchors.fill: parent
        color: theme.glass_color
        radius: area.radius
        opacity: 0.4
        state: "normal"

        Connections { target: sddm; onLoginFailed: { if (root.alert) glass.state = "alerting" }}
        Timer { id: timer; interval: 2000; onTriggered: glass.state = "normal" }

        states: [
            State {
                name: "normal"
                PropertyChanges { target: glass; color: theme.glass_color }
            },
            State {
                name: "alerting"
                PropertyChanges { target: glass; color: theme.error_color }
                PropertyChanges { target: timer; running: true }
            }
        ]

        transitions: [
            Transition {
                from: "normal"; to: "alerting"
                ColorAnimation { target: glass
                    property: "color"
                    duration: 0.25*timer.interval
                    easing.type: Easing.OutSine
                }
            },
            Transition {
                from: "alerting"; to: "normal"
                ColorAnimation { target: glass
                    property: "color"
                    duration: 0.75*timer.interval
                    easing.type: Easing.OutSine
                }
            }
        ]
    }
}
