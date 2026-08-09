import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*
    SongAndArtistText component structure:
        root (size set by CALLER: width/height, anchors, or Layout.*)
        └─ ColumnLayout (anchors.fill: parent)
            ├─ ScrollingText  ← alignment: root.textAlignment
            │                   width: fits text, capped at maxWidth
            └─ ScrollingText  ← alignment: root.textAlignment
                                width: fits text, capped at maxWidth
*/
Item {
    id: root

    enum TextPosition {
        Hidden,
        FirstLine,
        SecondLine
    }

    implicitWidth: songAndArtistText.implicitWidth
    implicitHeight: songAndArtistText.implicitHeight

    property var maxWidth: undefined
    property alias scrollingBehaviour: firstLine.overflowBehaviour
    property alias scrollingSpeed: firstLine.speed
    property alias scrollingResetOnPause: firstLine.scrollResetOnPause
    property alias scrollingEnabled: firstLine.scrollingEnabled
    property alias forcePauseScrolling: firstLine.forcePauseScrolling
    property alias truncateStyle: firstLine.truncateStyle
    property alias textColor: firstLine.color

    property string noMediaText: plasmoid.configuration.noMediaText

    property int titlePosition: SongAndArtistText.TextPosition.FirstLine
    property int artistsPosition: SongAndArtistText.TextPosition.FirstLine
    property int albumPosition: SongAndArtistText.TextPosition.Hidden

    property bool hideAlbumForSingles
    property bool showAlbum: !hideAlbumForSingles || (root.album != root.title)

    property font textFont: Kirigami.Theme.defaultFont
    property font boldTextFont: Qt.font(Object.assign({}, textFont, {weight: Font.Bold}))
    property string title
    property string artists
    property string album
    property int textAlignment: Qt.AlignHCenter

    property var firstLineArray: {
        const arr = [];

        if (artistsPosition == SongAndArtistText.TextPosition.FirstLine) arr.push(root.artists);
        if (titlePosition   == SongAndArtistText.TextPosition.FirstLine) arr.push(root.title);
        if (showAlbum && albumPosition == SongAndArtistText.TextPosition.FirstLine) arr.push(root.album);

        return arr;
    }

    property var secondLineArray: {
        const arr = [];

        if (artistsPosition == SongAndArtistText.TextPosition.SecondLine) arr.push(root.artists);
        if (titlePosition   == SongAndArtistText.TextPosition.SecondLine) arr.push(root.title);
        if (showAlbum && albumPosition == SongAndArtistText.TextPosition.SecondLine) arr.push(root.album);

        return arr;
    }

    property string finalFirstText:  firstLineArray.filter((x) => x).join(" - ")
    property string finalSecondText: secondLineArray.filter((x) => x).join(" - ")


    ColumnLayout {
        id: songAndArtistText
        anchors.fill: parent
        spacing: 0

        // first row of text (the only row, if there is only one)
        ScrollingText {
            id: firstLine
            Layout.alignment: textAlignment

            visible: text.length !== 0

            font: finalSecondText.length > 0 ? root.boldTextFont : root.textFont;
            maxWidth: root.maxWidth !== undefined ? root.maxWidth : root.width
            text: root.finalFirstText || root.finalSecondText ? root.finalFirstText : noMediaText
        }

        // second row of text
        ScrollingText {
            Layout.alignment: textAlignment

            visible: text.length !== 0

            font: root.textFont
            maxWidth: root.maxWidth !== undefined ? root.maxWidth : root.width
            text: root.finalSecondText

            overflowBehaviour: firstLine.overflowBehaviour
            speed: firstLine.speed
            scrollingEnabled: firstLine.scrollingEnabled
            scrollResetOnPause: firstLine.scrollResetOnPause
            color: firstLine.color
            forcePauseScrolling: firstLine.forcePauseScrolling
            truncateStyle: firstLine.truncateStyle
        }
    }
}
