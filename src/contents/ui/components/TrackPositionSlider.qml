import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.coreaddons 1.0 as KCoreAddons

Item {
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
            id: timeTrackSlider

            Layout.fillWidth: true
            value: container.songPosition / container.songLength
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

            // Disable the slider events when songLength is 0 or less
            Loader {
                anchors.fill: parent
                sourceComponent: container.songLength <= 0 ? sliderDisabler : null
                Component {
                    id: sliderDisabler
                    MouseArea {
                        onWheel: (wheel) => { wheel.accepted = true }
                        onClicked: (mouse) => { mouse.accepted = true }
                        onPressed: (mouse) => { mouse.accepted = true }
                    }
                }
            }
        }

        RowLayout {
            Layout.preferredWidth: parent.width
            id: timeLabels
            function formatDuration(duration) {
                if (container.songLength <= 0) {
                    return "-:--"
                }

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
