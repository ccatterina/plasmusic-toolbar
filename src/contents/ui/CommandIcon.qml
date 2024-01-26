import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: container
    property alias size: icon.width
    property bool active: false;
    property alias source: icon.source
    signal clicked()

    Layout.preferredWidth: size
    Layout.preferredHeight: size

    Kirigami.Icon {
        id: icon
        width: Kirigami.Units.iconSizes.small;
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