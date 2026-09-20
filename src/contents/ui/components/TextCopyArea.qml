import QtQuick
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: root

    property string text
    property string helpText

    PlasmaComponents3.ToolTip {
        id: copyTrackToolTip
        text: copyTimer.running
        ? i18n("Copied!")
        : root.helpText
        visible: copyTrackMouseArea.containsMouse || copyTimer.running
    }

    MouseArea {
        id: copyTrackMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            copyHelper.text = root.text
            copyHelper.selectAll()
            copyHelper.copy()
            copyHelper.deselect()
            copyTimer.restart()
        }
    }

    Timer {
        id: copyTimer
        interval: 1000
        repeat: false
    }

    TextEdit {
        id: copyHelper
        visible: false
        readOnly: true
    }
}
