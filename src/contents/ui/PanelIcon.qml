import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    enum Type {
        Icon,
        Image
    }

    id: root
    property int type: PanelIcon.Type.Icon
    property var imageUrl: null
    property var imageRadius: null
    property var icon: null
    property real size: Kirigami.Units.iconSizes.medium
    property bool imageReady: false
    property bool fallbackToIconWhenImageNotAvailable: false
    visible: type === PanelIcon.Type.Icon || imageReady || (fallbackToIconWhenImageNotAvailable && !imageReady)
    signal imageColorChanged(color: var)

    Layout.preferredHeight: size
    Layout.preferredWidth: size

    Kirigami.Icon {
        visible: type === PanelIcon.Type.Icon || (fallbackToIconWhenImageNotAvailable && !imageReady)
        id: iconComponent
        source: root.icon
        implicitHeight: root.size
        implicitWidth: root.size
        color: Kirigami.Theme.textColor
    }

    Timer {
        id: imageStatusTimer
        interval: 500
        onTriggered: {
            imageReady = imageComponent.status === Image.Ready
        }
    }

    Image {
        visible: type === PanelIcon.Type.Image
        width: root.size
        height: root.size
        id: imageComponent
        anchors.fill: parent
        source: root.imageUrl
        fillMode: Image.PreserveAspectFit
        onStatusChanged: {
            imageStatusTimer.restart()
            if (status === Image.Ready) imageColors.update()
        }

        // update color when image becomes visible, otherwise we get black color
        // sometimes, specially when the widget first loads
        onVisibleChanged: {
            if (status === Image.Ready) imageColors.update()
        }

        // enables round corners while the radius is set
        // ref: https://stackoverflow.com/questions/6090740/image-rounded-corners-in-qml
        layer.enabled: imageRadius > 0
        layer.effect: OpacityMask {
            maskSource: Item {
                width: imageComponent.width
                height: imageComponent.height
                Rectangle {
                    anchors.fill: parent
                    radius: imageRadius
                }
            }
        }
    }

    Kirigami.ImageColors {
        id: imageColors
        source: imageComponent
        onPaletteChanged: {
            imageColorChanged(dominant)
        }
    }
}
