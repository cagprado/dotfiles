import QtQuick 2.11

Item {
    property real size
    property alias currentIndex: list.currentIndex
    property alias model: list.model
    default property alias delegate: list.delegate
    property bool show: false
    visible: scale > 0

    property real item_height: 0
    property real item_width: 0
    property real margins: 0.5*size
    width: item_width + 2*margins
    height: Math.min(parent.height, list.count*item_height + 2*margins)

    // animate on scale
    transformOrigin: Item.Top
    scale: show && 1 || 0
    y: 0.1*(scale-1)*parent.y
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InCubic; } }

    ItemBackground {
        anchors.fill: parent
        radius: size
    }

    ListView { id: list
        anchors.fill: parent
        anchors.margins: margins
        snapMode: ListView.SnapToItem
        clip: true
        highlight: LoginMenuHighlight { }
        highlightMoveVelocity: 1000

        Keys.onEnterPressed: currentItem.activated()
        Keys.onReturnPressed: currentItem.activated()
        Keys.onSpacePressed: currentItem.activated()
        Keys.onEscapePressed: { event.accepted = true; show = false; }
    }

    Keys.forwardTo: [ list ]
}
