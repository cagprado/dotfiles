import QtQuick 2.0
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0

Item {
    property real radius
    property alias image: image.source

    width: 2*radius
    height: (1 + Math.cos(0.3*Math.PI))*radius

    Image { id: image
        visible: false
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    Item { id: mask
        visible: false
        anchors.fill: parent
        Rectangle { width: parent.width; height: width; radius: width }
    }

    OpacityMask {
        anchors.fill: mask
        maskSource: mask
        source: image
    }
}
