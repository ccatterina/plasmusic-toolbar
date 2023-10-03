import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3

// inspired by https://stackoverflow.com/a/49031115/2568933
Item {
    id: container

    property string text: ""
    property int maxWidth: 200 * units.devicePixelRatio
    property bool overflow: maxWidth <= textMetrics.width
    property string spacing: "      "
    property string combined: text + spacing
    property int step: 0
    property string display: overflow ? combined.slice(step) + combined.slice(0, step) : text
    property alias font: label.font
    property alias scrollingUpdateInterval: timer.interval

    clip: true
    width: overflow ? maxWidth : textMetrics.width + 10

    Layout.preferredHeight: label.implicitHeight
    Layout.preferredWidth: width

    TextMetrics {
        id: textMetrics
        font: label.font
        text: container.text
    }

    Timer {
        id: timer
        interval: 200
        running: overflow
        repeat: true
        onTriggered: () => {
            container.step = container.step >= combined.length - 1 ? 0 : container.step + 1
        }
    }

    PlasmaComponents3.Label {
        anchors.horizontalCenter: container.horizontalCenter
        id: label
        text: container.display
    }
}