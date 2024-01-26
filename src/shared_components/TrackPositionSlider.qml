import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    property bool disableUpdatePosition: false;
    property int songPosition: 0;  // Last song position detected in microseconds
    property int songLength: 0;  // Length of the entire song in microseconds;
    property bool playing: false;
    property alias enableChangePosition: timeTrackSlider.enabled;
    property alias refreshInterval: timer.interval;
    signal requireChangePosition(delta: int);  // delta: Position difference from current position in microseconds
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
                    container.requireChangePosition(Math.round(targetPosition - container.songPosition))
                }

                changingPosition = false
            }
        }

        RowLayout {
            Layout.preferredWidth: parent.width
            id: timeLabels
            function formatTommss(ms) {
                const date = new Date(null);
                date.setMilliseconds(ms);
                return date.toISOString().substr(14, 5);
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignLeft
                text: timeLabels.formatTommss(songPosition / 1000)
            }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                text: timeLabels.formatTommss((songLength - songPosition) / 1000)
            }
        }
    }
}
