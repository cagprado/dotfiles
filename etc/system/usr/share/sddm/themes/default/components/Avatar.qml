import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "."

MouseArea { id: avatar
    property real size
    property int index
    readonly property string username: model.name
    activeFocusOnTab: true
    onActiveFocusChanged: activeFocus || (focus = false)
    hoverEnabled: translate.rho == login.rho0
    anchors.fill: parent
    state: current_user < 0 && "normal" || "selected"

    onEntered: focus = true
    onExited: focus = false
    onClicked: select(model.index)
    Keys.onEnterPressed: select(model.index)
    Keys.onReturnPressed: select(model.index)
    Keys.onSpacePressed: select(model.index)

    ItemBackground {
        anchors.fill: parent
        highlight: avatar.focus
        alert: true
    }

    Face { id: face
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0.1*login.width
        radius: 0.4*login.width
        image: model.icon
    }
    Text { id: text
        anchors.top: face.bottom
        anchors.horizontalCenter: face.horizontalCenter
        font.pixelSize: size
        text: avatar.scale > login.circle_scale && model.realName || model.name
    }

    transform: Translate { id: translate
        property real rho
        property real phi
        x: rho*Math.sin(phi); y: -rho*Math.cos(phi)
    }

    states: [
        State {
            name: "normal"
            PropertyChanges { target: avatar
                scale: login.circle_scale
                z: index
            }
            PropertyChanges { target: translate
                rho: login.rho0
                phi: login.phi0*model.index
            }
        },
        State {
            name: "selected"
            PropertyChanges { target: avatar
                scale: (current_user < 0 && index == 0) || (current_user == model.index) && 1 || 0
                z: -index
            }
            PropertyChanges { target: translate
                phi: login.phi0*model.index - 2*Math.PI
            }
        }
    ]

    transitions: Transition {
        from: "normal"; to: "selected"; reversible: true
        SequentialAnimation {
            NumberAnimation { target: translate
                properties: "rho,phi"
                duration: 300
                easing.type: Easing.InExpo
            }
            NumberAnimation { target: avatar
                property: "scale"
                duration: 400
                easing.type: Easing.OutQuad
            }
            ScriptAction { script: current_user == model.index && (show_controls = true) }
        }
    }

    Timer { id: timer
        interval: index*500/userModel.count
        onTriggered: avatar.state = current_user < 0 ? "normal" : "selected"
    }

    Connections {
        target: login
        onCurrent_userChanged: timer.running = true
    }

    Component.onCompleted: state = state
}
