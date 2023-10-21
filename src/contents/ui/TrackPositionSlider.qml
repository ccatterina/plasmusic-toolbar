import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    property var startWaitingForPositionChange: null;
    property int songPosition: 0;  // Last song position detected in microseconds
    property date lastSongPositionUpdate: new Date();  // Datetime of the last songPosition update.
    property int songLength: 0;  // Length of the entire song in microseconds;
    property bool playing: false;
    property alias enableChangePosition: timeTrackSlider.enabled;
    property alias refreshInterval: timer.interval;
    signal changePosition(delta: int);  // Position difference from current position in microseconds

    Layout.preferredHeight: column.implicitHeight
    Layout.fillWidth: true

    onSongPositionChanged: () => {
        startWaitingForPositionChange = null;
    }

    id: container

    Timer {
        function formatTommss(ms) {
            const date = new Date(null);
            date.setMilliseconds(ms);
            return date.toISOString().substr(14, 5);
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
            timeSinceStart.text = formatTommss(msSinceStart)
            const msToEnd = (container.songLength / 1000) - msSinceStart
            timeToEnd.text = `-${formatTommss(msToEnd)}`
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
