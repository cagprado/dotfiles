import QtQuick 2.11

FocusScope { id: login
    property real size
    property bool show_controls: current_user >= 0
    property int current_session: sessionModel.lastIndex
    property int current_user: theme.show_last_user || userModel.count == 1
                               ? Math.min(userModel.lastIndex, userModel.count-1)
                               : -1

    readonly property real phi0: 2*Math.PI/userModel.count
    readonly property real sinphi0: Math.sin(0.5*phi0)
    readonly property real rho0: Math.min(3*size / sinphi0, 0.3*wallpaper.height)
    readonly property real circle_scale: 1.8*rho0*sinphi0 / height
    focus: true

    height: 12*size
    width: height

    signal request_login(string password)
    onRequest_login: sddm.login(users.itemAt(current_user).username, password, current_session)

    signal select(int index)
    onSelect: {
        if (userModel.count > 1) {
            show_controls = false;
            current_user = (current_user < 0) ? index : (current_user - userModel.count - 1);
        }
    }

    Item { id: selection_menus
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.margins: size
        height: 0.5*(window.height - login.height) - 2*size

        LoginMenu { id: session
            anchors.horizontalCenter: parent.horizontalCenter
            size: 0.5*login.size
            model: sessionModel
            currentIndex: current_session
            LoginMenuItem {
                text: model.name
                icon: "../assets/session-" + theme.get_session_name(model.name) + ".svgz"
                altIcon: "../assets/session-unknown.svgz"
                highlight: index == current_session
                onActivated: {
                    current_session = index;
                    password.forceActiveFocus();
                }
            }
        }

        LoginMenu { id: kbdmenu
            anchors.horizontalCenter: parent.horizontalCenter
            size: 0.5*login.size
            model: keyboard.layouts
            currentIndex: keyboard.currentLayout
            LoginMenuItem {
                text: modelData.longName || "[unknown]"
                icon: "/usr/share/sddm/flags/%1.png".arg(modelData.shortName)
                altIcon: "../assets/keyboard-unknown.svgz"
                highlight: index == keyboard.currentLayout
                onActivated: {
                    keyboard.currentLayout = index;
                    password.forceActiveFocus();
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: current_user >= 0 && select(0)
        FocusScope {
            anchors.fill: parent
            enabled: current_user < 0
            Repeater { id: users
                model: userModel
                delegate: Avatar {
                    size: login.size
                    index: model.index - current_user - 1 - Math.floor((model.index - current_user - 1)/userModel.count)*userModel.count
                }
            }
        }
    }

    Item { id: controls
        property bool show: show_controls
        anchors.centerIn: parent
        enabled: visible
        visible: opacity > 0
        opacity: show && 1 || 0
        onEnabledChanged: enabled && password.forceActiveFocus() || (password.reset())

        LoginPassword { id: password
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 2*login.size
            size: 0.5*login.size
        }

        LoginControls {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 5*login.size
            size: 0.4*login.size
            Keys.onEscapePressed: password.forceActiveFocus()
        }

        Behavior on opacity { PropertyAnimation { duration: 100 }}
    }

    signal session_show(int t)
    signal keyboard_show(int t)
    onSession_show: session.show = (t == -1) ? !session.show : t
    onKeyboard_show: kbdmenu.show = (t == -1) ? !kbdmenu.show : t
}
