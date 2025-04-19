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
    property bool imageReady: imageComponent.status == Image.Ready
    property string imageColor: imageColors.dominant
    property bool fallbackToIconWhenImageNotAvailable: false
    visible: type === PanelIcon.Type.Icon || imageReady || (fallbackToIconWhenImageNotAvailable && !imageReady)


    implicitHeight: size
    implicitWidth: images.implicitWidth

    // Kirigami.Icon {
    //     visible: type === PanelIcon.Type.Icon || (fallbackToIconWhenImageNotAvailable && !imageReady)
    //     id: iconComponent
    //     source: root.icon
    //     anchors.fill: parent
    //     color: Kirigami.Theme.textColor
    // }

    Timer {
        id: imageStatusTimer
        interval: 500
        onTriggered: {
            imageReady = imageComponent.status === Image.Ready
        }
    }

    RowLayout {
        id: images
        anchors.fill: parent
        Image {
            // visible: type === PanelIcon.Type.Image
            Layout.preferredHeight: root.size
            Layout.preferredWidth: root.size
            id: imageComponent
            source: root.imageUrl
            fillMode: Image.PreserveAspectFit
            cache: false
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

        Image {
            // visible: type === PanelIcon.Type.Image
            Layout.preferredHeight: root.size
            Layout.preferredWidth: root.size
            smooth: true
            id: imageComponent1
            source: root.imageUrl
            fillMode: Image.PreserveAspectFit
            cache: false

            // enables round corners while the radius is set
            // ref: https://stackoverflow.com/questions/6090740/image-rounded-corners-in-qml
            layer.enabled: imageRadius > 0
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: imageComponent1.width
                    height: imageComponent1.height
                    Rectangle {
                        anchors.fill: parent
                        radius: imageRadius
                    }
                }
            }
        }


        Image {
            // visible: type === PanelIcon.Type.Image
            Layout.preferredHeight: root.size
            Layout.preferredWidth: root.size
            mipmap: true
            id: imageComponent2
            source: root.imageUrl
            fillMode: Image.PreserveAspectFit
            cache: false

            // enables round corners while the radius is set
            // ref: https://stackoverflow.com/questions/6090740/image-rounded-corners-in-qml
            layer.enabled: imageRadius > 0
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: imageComponent2.width
                    height: imageComponent2.height
                    Rectangle {
                        anchors.fill: parent
                        radius: imageRadius
                    }
                }
            }
        }
    }

    Kirigami.ImageColors {
        id: imageColors
        source: imageComponent
    }
}
