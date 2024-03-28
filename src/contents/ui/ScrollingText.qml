import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3

// inspired by https://stackoverflow.com/a/49031115/2568933
Item {
    id: root

    enum OverflowBehaviour {
        AlwaysScroll,
        ScrollOnMouseOver,
        StopScrollOnMouseOver
    }

    property int overflowBehaviour: ScrollingText.OverflowBehaviour.AlwaysScroll

    property string text: ""
    readonly property string spacing: "     "
    readonly property string textAndSpacing: text + spacing

    property int maxWidth: 200 * units.devicePixelRatio
    readonly property bool overflow: maxWidth <= textMetrics.width
    property int speed: 5;
    readonly property int duration: (25 * (11 - speed) + 25)* textAndSpacing.length;

    readonly property bool pauseScrolling: {
        if (overflowBehaviour === ScrollingText.OverflowBehaviour.AlwaysScroll) {
            return false;
        } else if (overflowBehaviour === ScrollingText.OverflowBehaviour.ScrollOnMouseOver) {
            return !mouse.hovered;
        } else if (overflowBehaviour === ScrollingText.OverflowBehaviour.StopScrollOnMouseOver) {
            return mouse.hovered;
        }
    }

    property alias font: label.font

    width: overflow ? maxWidth : textMetrics.width + 10
    clip: true

    Layout.preferredHeight: label.implicitHeight
    Layout.preferredWidth: width
    Layout.alignment: Qt.AlignHCenter

    HoverHandler {
        id: mouse
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    TextMetrics {
        id: textMetrics
        font: label.font
        text: root.text
    }

    PlasmaComponents3.Label {
        id: label
        text: overflow ? root.textAndSpacing : root.text

        NumberAnimation on x {
            running: root.overflow
            paused: root.pauseScrolling
            from: 0
            to: -label.implicitWidth
            duration: root.duration
            loops: Animation.Infinite

            function reset() {
                label.x = 0;
                if (running) {
                    restart()
                }
                if (root.pauseScrolling) {
                    pause()
                }
            }

            onToChanged: () => reset()
            onDurationChanged: () =>  reset()
        }

        PlasmaComponents3.Label {
            visible: overflow
            anchors.left: parent.right

            font: label.font
            text: label.text
        }
    }
}
