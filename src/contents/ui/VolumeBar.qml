import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: container
    property real volume: 0.5;
    property real size: 3;
    property real iconSize: Kirigami.Units.iconSizes.small;
    signal setVolume(newVolume: real)
    signal volumeUp()
    signal volumeDown()

    Layout.fillWidth: true
    Layout.preferredHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.fill: parent

        CommandIcon {
            size: iconSize;
            onClicked: container.volumeDown()
            source: 'audio-volume-low';
        }
        Rectangle {
            MouseAreaWithWheelHandler {
                anchors.centerIn: parent
                height: parent.height + 8
                width: parent.width
                cursorShape: Qt.PointingHandCursor
                onClicked: ({x}) => {
                    container.setVolume(x/parent.width)
                }
                onPositionChanged: (mouse) => {
                    if (pressed) container.setVolume(mouse.x/parent.width)
                }
                onWheelUp: {
                    container.volumeUp();
                }
                onWheelDown: {
                    container.volumeDown();
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
            onClicked: container.volumeUp()
            source: 'audio-volume-high';
        }
    }
}
