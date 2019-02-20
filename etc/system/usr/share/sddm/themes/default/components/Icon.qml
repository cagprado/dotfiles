import QtQuick 2.11

Image {
    property real size
    property url alternativeSource

    width: size
    height: size
    sourceSize.width: size
    sourceSize.height: size
    fillMode: Image.PreserveAspectFit
    Component.onCompleted: status == Image.Error && (source = alternativeSource)
}
