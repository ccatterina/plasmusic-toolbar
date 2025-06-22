import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami


ColumnLayout {
    id: root

    enum TextPosition {
        Hidden,
        FirstLine,
        SecondLine
    }

    property var maxWidth: undefined
    property var scrollingBehaviour: undefined
    property var scrollingSpeed: undefined
    property var scrollingResetOnPause: undefined
    property var scrollingEnabled: undefined
    property var forcePauseScrolling: undefined
    property var truncateStyle: undefined

    property string noMediaText: plasmoid.configuration.noMediaText

    property int titlePosition: SongAndArtistText.TextPosition.FirstLine
    property int artistsPosition: SongAndArtistText.TextPosition.FirstLine
    property int albumPosition: SongAndArtistText.TextPosition.Hidden

    property font textFont: Kirigami.Theme.defaultFont
    property font boldTextFont: Qt.font(Object.assign({}, textFont, {weight: Font.Bold}))
    property string color: Kirigami.Theme.textColor
    property string title
    property string artists
    property string album
    property int textAlignment: Qt.AlignHCenter

    spacing: 0


    property var firstLineArray: {
        const arr = [];

        if (artistsPosition == SongAndArtistText.TextPosition.FirstLine) arr.push(root.artists);
        if (titlePosition   == SongAndArtistText.TextPosition.FirstLine) arr.push(root.title);
        if (albumPosition   == SongAndArtistText.TextPosition.FirstLine) arr.push(root.album);

        return arr;
    }

    property var secondLineArray: {
        const arr = [];

        if (artistsPosition == SongAndArtistText.TextPosition.SecondLine) arr.push(root.artists);
        if (titlePosition   == SongAndArtistText.TextPosition.SecondLine) arr.push(root.title);
        if (albumPosition   == SongAndArtistText.TextPosition.SecondLine) arr.push(root.album);

        return arr;        
    }

    property string finalFirstText:  firstLineArray.filter((x) => x).join(" - ")
    property string finalSecondText: secondLineArray.filter((x) => x).join(" - ")

    // first row of text (the only row, if there is only one)
    ScrollingText {
        // visible only when necessary
        visible: text.length !== 0
        overflowBehaviour: root.scrollingBehaviour
        font: finalSecondText.length > 0 ? root.boldTextFont : root.textFont;
        speed: root.scrollingSpeed
        maxWidth: root.maxWidth

        text: root.finalFirstText || root.finalSecondText ? root.finalFirstText : noMediaText

        scrollingEnabled: root.scrollingEnabled
        scrollResetOnPause: root.scrollingResetOnPause
        textColor: root.color
        forcePauseScrolling: root.forcePauseScrolling
        truncateStyle: root.truncateStyle
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
        truncateStyle: root.truncateStyle
        Layout.alignment: root.textAlignment
    }
}
