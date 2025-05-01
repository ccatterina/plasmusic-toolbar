import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: container
    property real volume: 0.5;
    property real size: 3;
    property real iconSize: Kirigami.Units.iconSizes.small;
    readonly property real minVolume: 0.0;
    readonly property real maxVolume: 1.0;
    readonly property real clampedVolume: clampVolume(volume);

    signal setVolume(newVolume: real)
    signal volumeUp()
    signal volumeDown()

    function clampVolume(value) {
        return Math.max(minVolume, Math.min(maxVolume, value));
    }

    Layout.fillWidth: true
    Layout.preferredHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.fill: parent

        CommandIcon {
            size: iconSize;
            onClicked: () => {
                if (container.volume > container.minVolume) container.volumeDown();
            }
            source: 'audio-volume-low';
        }

        Rectangle {
            MouseAreaWithWheelHandler {
                anchors.centerIn: parent
                height: parent.height + 8
                width: parent.width
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    container.setVolume(container.clampVolume(mouse.x / parent.width))
                }
                onPositionChanged: (mouse) => {
                    if (pressed) container.setVolume(container.clampVolume(mouse.x / parent.width));
                }
                onWheelUp: () => {
                    if (container.volume < container.maxVolume) container.volumeUp();
                }
                onWheelDown: () => {
                    if (container.volume > container.minVolume) container.volumeDown();
                }
            }

            height: container.size
            Layout.fillWidth: true
            id: full
            color: Kirigami.Theme.disabledTextColor

            Rectangle {
                Layout.alignment: Qt.AlignLeft
                height: container.size
                width: full.width * clampedVolume;
                color: Kirigami.Theme.highlightColor
            }
        }

        CommandIcon {
            size: iconSize;
            onClicked: () => {
                if (container.volume < container.maxVolume) container.volumeUp();
            }
            source: 'audio-volume-high';
        }
    }
}
