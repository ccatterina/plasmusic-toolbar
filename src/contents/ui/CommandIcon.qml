import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.12

Item {
    id: container
    property alias size: icon.width
    property bool active: false;
    property alias source: icon.source
    signal clicked()

    Layout.preferredWidth: size
    Layout.preferredHeight: size

    PlasmaCore.IconItem {
        id: icon
        width: PlasmaCore.Units.iconSizes.small;
        height: width;

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: container.clicked()
        }
        ColorOverlay {
            id: overlay
            visible: active
            anchors.fill: icon
            source: icon
            color: PlasmaCore.Theme.positiveTextColor
        }
    }
}