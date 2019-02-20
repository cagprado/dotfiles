import QtQuick 2.11

Text {
    color: theme.text_color
    font.family: theme.typeface
    font.pixelSize: theme.scale
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    style: Text.Raised
    styleColor: theme.shadow_color
    textFormat: Text.PlainText
}
