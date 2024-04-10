import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kcoreaddons 1.0 as KCoreAddons


Item {
    property var startWaitingForPositionChange: null;
    property double songPosition: 0;  // Last song position detected in microseconds
    property date lastSongPositionUpdate: new Date();  // Datetime of the last songPosition update.
    property double songLength: 0;  // Length of the entire song in microseconds;
    property bool playing: false;
    property alias enableChangePosition: timeTrackSlider.enabled;
    property alias refreshInterval: timer.interval;
    signal changePosition(delta: double);  // Position difference from current position in microseconds

    Layout.preferredHeight: column.implicitHeight
    Layout.fillWidth: true

    onSongPositionChanged: () => {
        startWaitingForPositionChange = null;
    }

    id: container

    Timer {
        function formatDuration(ms) {
            const hideHours = container.songLength < 3600000000 // 1 hour in microseconds
            const durationFormatOption = hideHours ? KCoreAddons.FormatTypes.FoldHours : KCoreAddons.FormatTypes.DefaultDuration
            return KCoreAddons.Format.formatDuration(ms, durationFormatOption)
        }

        id: timer
        interval: 200;
        running: container.playing && !timeTrackSlider.pressed;
        repeat: true
        onTriggered: () => {
            // FIXME: find a better way to handle this situation
            // Stop to do things in order to avoid slider refreshes during position change operation.
            // The timer restart when the songPosition change or, in any case, after 500ms.
            if (startWaitingForPositionChange && new Date() - startWaitingForPositionChange < 500) {
                return
            }

            const msSinceStart = (container.songPosition / 1000) + (new Date() - container.lastSongPositionUpdate)
            timeSinceStart.text = timer.formatDuration(msSinceStart)
            const msToEnd = (container.songLength / 1000) - msSinceStart
            timeToEnd.text = `-${timer.formatDuration(msToEnd)}`
            timeTrackSlider.value = msSinceStart / (container.songLength / 1000)
        }
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: 0

        PlasmaComponents3.Slider {
            Layout.fillWidth: true
            id: timeTrackSlider
            value: 0

            onPressedChanged: () => {
                if (!pressed) {
                    timeTrackSlider.moved(value)
                }
            }
            onMoved: {
                if (pressed) {
                    return
                }

                const currentPosition = container.songPosition + (new Date() - container.lastSongPositionUpdate) * 1000
                const targetPosition = timeTrackSlider.value * container.songLength
                if (targetPosition == currentPosition) {
                    return
                }

                container.startWaitingForPositionChange = new Date()
                container.changePosition(Math.round(targetPosition - currentPosition))
            }
        }

        RowLayout {
            Layout.preferredWidth: parent.width

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignLeft
                id: timeSinceStart
            }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                id: timeToEnd
            }
        }
    }
}
