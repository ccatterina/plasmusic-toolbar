import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var lyrics: []
    property double songPosition: 0  // microseconds
    property font textFont: Kirigami.Theme.defaultFont
    property bool loading: false

    Layout.fillWidth: true

    property int _currentLyricIndex: 0

    function findCurrentIndex() {
        if (!lyrics || lyrics.length === 0) return 0
        const posMs = songPosition / 1000
        const cur = _currentLyricIndex

        // Normal playback: check if we're still on the current line or moved to the next
        if (cur < lyrics.length && lyrics[cur].time <= posMs) {
            if (cur + 1 >= lyrics.length || lyrics[cur + 1].time > posMs) {
                return cur
            }
            if (cur + 2 >= lyrics.length || lyrics[cur + 2].time > posMs) {
                return cur + 1
            }
        }

        // Seek or large jump: fall back to reverse linear scan
        for (let i = lyrics.length - 1; i >= 0; i--) {
            if (lyrics[i].time <= posMs) return i
        }
        return 0
    }

    onSongPositionChanged: {
        if (!lyrics || lyrics.length === 0) return
        const idx = findCurrentIndex()
        if (idx !== _currentLyricIndex) {
            _currentLyricIndex = idx
        }
    }

    onLyricsChanged: {
        _currentLyricIndex = 0
    }

    PlasmaComponents3.BusyIndicator {
        anchors.centerIn: parent
        visible: root.loading
        running: visible
    }

    PlasmaComponents3.Label {
        anchors.centerIn: parent
        visible: !root.loading && (!root.lyrics || root.lyrics.length === 0)
        text: i18n("No synced lyrics available")
        opacity: 0.6
        font: root.textFont
        color: Kirigami.Theme.textColor
    }

    ListView {
        id: lyricsListView
        anchors.fill: parent
        visible: !root.loading && root.lyrics && root.lyrics.length > 0
        model: root.lyrics
        clip: true
        interactive: true
        currentIndex: root._currentLyricIndex
        cacheBuffer: 2000

        preferredHighlightBegin: height / 2 - 30
        preferredHighlightEnd: height / 2 + 30
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 500
        highlightMoveVelocity: -1

        highlight: Item {}

        delegate: Item {
            width: lyricsListView.width
            height: lyricLabel.implicitHeight + Kirigami.Units.smallSpacing * 2

            required property int index
            required property var modelData

            readonly property bool isActive: index === lyricsListView.currentIndex

            PlasmaComponents3.Label {
                id: lyricLabel
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing

                text: modelData.text
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Kirigami.Theme.textColor
                font.family: root.textFont.family
                font.pointSize: parent.isActive
                    ? root.textFont.pointSize * 1.1
                    : root.textFont.pointSize
                font.bold: parent.isActive

                opacity: parent.isActive ? 1.0 : 0.35

                Behavior on opacity {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
