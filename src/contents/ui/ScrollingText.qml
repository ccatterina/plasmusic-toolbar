import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3

// inspired by https://stackoverflow.com/a/49031115/2568933
Item {
    id: root

    property string text: ""
    readonly property string spacing: "     "
    readonly property string textAndSpacing: text + spacing

    property int maxWidth: 200 * units.devicePixelRatio
    readonly property bool overflow: maxWidth <= textMetrics.width
    property int speed: 5;
    readonly property int duration: (25 * (11 - speed) + 25)* textAndSpacing.length;

    property alias font: label.font

    width: overflow ? maxWidth : textMetrics.width + 10
    clip: true

    Layout.preferredHeight: label.implicitHeight
    Layout.preferredWidth: width
    Layout.alignment: Qt.AlignHCenter

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
            from: 0
            to: -label.implicitWidth
            duration: root.duration
            loops: Animation.Infinite

            function reset() {
                label.x = 0;
                if (running) {
                    restart()
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