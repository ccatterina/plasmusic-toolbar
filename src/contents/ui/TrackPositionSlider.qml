import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.coreaddons 1.0 as KCoreAddons

Item {
    property bool disableUpdatePosition: false;
    property double songPosition: 0;  // Last song position detected in microseconds
    property double songLength: 0;  // Length of the entire song in microseconds;
    property bool playing: false;
    property alias enableChangePosition: timeTrackSlider.enabled;
    property alias refreshInterval: timer.interval;
    signal requireChangePosition(position: double);
    signal requireUpdatePosition();

    Layout.preferredHeight: column.implicitHeight
    Layout.fillWidth: true

    id: container

    Timer {
        id: timer
        interval: 200;
        running: container.playing && !timeTrackSlider.pressed && !timeTrackSlider.changingPosition;
        repeat: true
        onTriggered: () => {
            container.requireUpdatePosition()
        }
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: 0

        PlasmaComponents3.Slider {
            Layout.fillWidth: true
            id: timeTrackSlider
            value: songPosition / songLength
            property bool changingPosition: false

            onPressedChanged: () => {
                if (!pressed) {
                    timeTrackSlider.moved()
                }
            }
            onMoved: {
                if (pressed) {
                    return
                }

                changingPosition = true
                const targetPosition = timeTrackSlider.value * container.songLength
                if (targetPosition != container.songPosition) {
                    container.requireChangePosition(targetPosition)
                }
                changingPosition = false
            }
        }

        RowLayout {
            Layout.preferredWidth: parent.width
            id: timeLabels
            function formatDuration(duration) {
                const hideHours = container.songLength < 3600000000 // 1 hour in microseconds
                const durationFormatOption = hideHours ? KCoreAddons.FormatTypes.FoldHours : KCoreAddons.FormatTypes.DefaultDuration
                return KCoreAddons.Format.formatDuration(duration / 1000, durationFormatOption)
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignLeft
                text: timeLabels.formatDuration(container.songPosition)
            }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                text: timeLabels.formatDuration(container.songLength - container.songPosition)
            }
        }
    }
}
