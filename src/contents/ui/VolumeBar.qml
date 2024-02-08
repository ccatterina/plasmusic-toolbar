import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: container
    property real volume: 0.5;
    property real size: 3;
    property real iconSize: Kirigami.Units.iconSizes.small;
    signal changeVolume(newVolume: real);

    Layout.fillWidth: true
    Layout.preferredHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.fill: parent

        CommandIcon {
            size: iconSize;
            onClicked: container.changeVolume(container.volume - 0.1 > 1 ? 1 : container.volume - 0.1)
            source: 'audio-volume-low';
        }
        Rectangle {
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ({x}) => {
                    container.changeVolume(x/parent.width)
                }
            }

            height: container.size
            Layout.fillWidth: true
            id: full
            color: Kirigami.Theme.disabledTextColor

            Rectangle {
                Layout.alignment: Qt.AlignLeft
                height: container.size
                width: full.width * container.volume
                color: Kirigami.Theme.highlightColor
            }
        }
        CommandIcon {
            size: iconSize;
            onClicked: container.changeVolume(container.volume + 0.1 > 1 ? 1 : container.volume + 0.1);
            source: 'audio-volume-high';
        }
    }
}