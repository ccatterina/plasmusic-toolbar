import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami


ColumnLayout {
    id: root

    property int maxWidth: undefined
    property int scrollingBehaviour: undefined
    property int scrollingSpeed: undefined
    property bool scrollingResetOnPause: undefined
    property bool scrollingEnabled: undefined
    property bool forcePauseScrolling: undefined
    property bool splitSongAndArtists: false
    property bool showAlbumTitle: true
    property bool albumBeneathSongAndArtists: true

    property font textFont: Kirigami.Theme.defaultFont
    // property font boldTextFont: Qt.font(Object.assign({}, textFont, {weight: Font.Bold}))
    // property font italicTextFont: Qt.font(Object.assign({}, textFont, {italic: true}))
    property string color: Kirigami.Theme.textColor
    property string title
    property string artists
    property string album
    property int textAlignment: Qt.AlignHCenter

    spacing: 0

    // [root.artists, root.title].filter((x) => x).join(" - ")

    property string formattedTitle: `<b>${root.title}</b>`
    property string formattedArtists: `${root.artists}`
    property string formattedAlbum: `<i>${root.album}</i>`

    property string finalFirstText: {
        if (root.showAlbumTitle) {
            if (root.albumBeneathSongAndArtists) {
                if (splitSongAndArtists) {
                    return formattedTitle
                } else {
                    return [formattedArtists,formattedTitle].filter((x) => x).join(" - ")
                }
            } else {
                if (splitSongAndArtists) {
                    return [formattedTitle,formattedAlbum].filter((x) => x).join(" - ")
                } else {
                    return [formattedArtists,formattedTitle,formattedAlbum].filter((x) => x).join(" - ")
                }
            }
        } else {
            if (root.splitSongAndArtists) {
                return formattedTitle
            } else {
                return [formattedArtists,formattedTitle].filter((x) => x).join(" - ")
            }
        }
    }

    property string finalSecondText: {
        if (root.showAlbumTitle) {
            if (root.albumBeneathSongAndArtists) {
                if (splitSongAndArtists) {
                    return [formattedArtists,formattedAlbum].filter((x) => x).join(" - ")
                } else {
                    return formattedAlbum
                }
            } else {
                if (splitSongAndArtists) {
                    return formattedArtists
                } else {
                    return ""
                }
            }
        } else {
            if (root.splitSongAndArtists) {
                return formattedArtists
            } else {
                return ""
            }
        }
    }

    // first row of text (the only row, if there is only one)
    ScrollingText {
        // always visible
        overflowBehaviour: root.scrollingBehaviour
        font: root.textFont
        speed: root.scrollingSpeed
        maxWidth: root.maxWidth

        text: root.finalFirstText

        scrollingEnabled: root.scrollingEnabled
        scrollResetOnPause: root.scrollingResetOnPause
        textColor: root.color
        forcePauseScrolling: root.forcePauseScrolling
        Layout.alignment: root.textAlignment
    }

    // second row of text
    ScrollingText {
        // visible only when necessary
        visible: text.length !== 0
        overflowBehaviour: root.scrollingBehaviour
        font: root.textFont
        speed: root.scrollingSpeed
        maxWidth: root.maxWidth

        text: root.finalSecondText
        
        scrollingEnabled: root.scrollingEnabled
        scrollResetOnPause: root.scrollingResetOnPause
        textColor: root.color
        forcePauseScrolling: root.forcePauseScrolling
        Layout.alignment: root.textAlignment
    }

    // // top text
    // ScrollingText {
    //     visible: root.splitSongAndArtists
    //     overflowBehaviour: root.scrollingBehaviour
    //     font: root.boldTextFont
    //     speed: root.scrollingSpeed
    //     maxWidth: root.maxWidth
    //     text: root.title
    //     scrollingEnabled: root.scrollingEnabled
    //     scrollResetOnPause: root.scrollingResetOnPause
    //     textColor: root.color
    //     forcePauseScrolling: root.forcePauseScrolling
    //     Layout.alignment: root.textAlignment
    // }

    // // second row of text
    // ScrollingText {
    //     overflowBehaviour: root.scrollingBehaviour
    //     font: root.textFont
    //     speed: root.scrollingSpeed
    //     maxWidth: root.maxWidth
    //     text: root.splitSongAndArtists ? root.artists : [root.artists, root.title].filter((x) => x).join(" - ")
    //     scrollingEnabled: root.scrollingEnabled
    //     scrollResetOnPause: root.scrollingResetOnPause
    //     visible: text.length !== 0
    //     textColor: root.color
    //     forcePauseScrolling: root.forcePauseScrolling
    //     Layout.alignment: root.textAlignment
    // }
}