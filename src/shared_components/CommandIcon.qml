import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.4 as Kirigami

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
        color: container.active ? PlasmaCore.Theme.positiveTextColor : PlasmaCore.Theme.textColor

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: container.clicked()
        }
    }
}