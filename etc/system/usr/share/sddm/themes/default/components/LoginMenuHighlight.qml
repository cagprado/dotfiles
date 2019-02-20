import QtQuick 2.11
import QtGraphicalEffects 1.0

RadialGradient { id: root
    property color color: theme.text_color
    horizontalOffset: 0.4*width
    horizontalRadius: 2*width

    gradient: Gradient {
        GradientStop { position: 0; color: Qt.rgba(root.color.r, root.color.g, root.color.b, 0.5) }
        GradientStop { position: 0.5; color: "transparent" }
    }
}
