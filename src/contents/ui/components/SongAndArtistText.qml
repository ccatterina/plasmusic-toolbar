import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami


ColumnLayout {
    id: root

    property int maxWidth
    property int scrollingBehaviour
    property int scrollingSpeed
    property bool scrollingResetOnPause
    property bool scrollingEnabled
    property bool splitSongAndArtists: false
    property font textFont: Kirigami.Theme.defaultFont
    property font boldTextFont: Qt.font(Object.assign({}, textFont, {weight: Font.Bold}))
    property string color: Kirigami.Theme.textColor
    property string title
    property string artists

    spacing: 0

    ScrollingText {
        visible: root.splitSongAndArtists
        overflowBehaviour: root.scrollingBehaviour
        font: root.boldTextFont
        speed: root.scrollingSpeed
        maxWidth: root.maxWidth
        text: root.title
        scrollingEnabled: root.scrollingEnabled
        scrollResetOnPause: root.scrollingResetOnPause
        textColor: root.color
    }

    ScrollingText {
        overflowBehaviour: root.scrollingBehaviour
        font: root.textFont
        speed: root.scrollingSpeed
        maxWidth: root.maxWidth
        text: root.splitSongAndArtists ? root.artists : [root.artists, root.title].filter((x) => x).join(" - ")
        scrollingEnabled: root.scrollingEnabled
        scrollResetOnPause: root.scrollingResetOnPause
        visible: text.length !== 0
        textColor: root.color
    }
}