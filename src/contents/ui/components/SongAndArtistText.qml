import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami


ColumnLayout {
    id: root

    property var maxWidth: undefined
    property var scrollingBehaviour: undefined
    property var scrollingSpeed: undefined
    property var scrollingResetOnPause: undefined
    property var scrollingEnabled: undefined
    property var forcePauseScrolling: undefined

    // 0 is hidden, 1 is first line, 2 is second line

    property int titlePosition: 1
    property int artistsPosition: 1
    property int albumPosition: 0

    property font textFont: Kirigami.Theme.defaultFont
    // property font boldTextFont: Qt.font(Object.assign({}, textFont, {weight: Font.Bold}))
    // property font italicTextFont: Qt.font(Object.assign({}, textFont, {italic: true}))
    property string color: Kirigami.Theme.textColor
    property string title
    property string artists
    property string album
    property int textAlignment: Qt.AlignHCenter

    spacing: 0

    property string formattedTitle: `${root.title}`
    property string formattedArtists: `${root.artists}`
    property string formattedAlbum: `${root.album}`

    property var firstLineArray: {
        const arr = [];

        if (artistsPosition == 1) arr.push(root.formattedArtists);
        if (titlePosition   == 1) arr.push(root.formattedTitle);
        if (albumPosition   == 1) arr.push(root.formattedAlbum);

        return arr;
    }

    property var secondLineArray: {
        const arr = [];

        if (artistsPosition == 2) arr.push(root.formattedArtists);
        if (titlePosition   == 2) arr.push(root.formattedTitle);
        if (albumPosition   == 2) arr.push(root.formattedAlbum);

        return arr;        
    }

    property string finalFirstText:  firstLineArray.filter((x) => x).join(" - ")
    property string finalSecondText: secondLineArray.filter((x) => x).join(" - ")

    // ONLY USED FOR FULL.qml
    property var thirdLineArray: {
        const arr = [];

        if (artistsPosition == 3) arr.push(root.formattedArtists);
        if (titlePosition   == 3) arr.push(root.formattedTitle);
        if (albumPosition   == 3) arr.push(root.formattedAlbum);

        return arr;   
    }

    property string finalThirdText: thirdLineArray.filter((x) => x).join(" - ")

    // first row of text (the only row, if there is only one)
    ScrollingText {
        // visible only when necessary
        visible: text.length !== 0
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

    ScrollingText {
        // visible only when necessary
        visible: text.length !== 0
        overflowBehaviour: root.scrollingBehaviour
        font: root.textFont
        speed: root.scrollingSpeed
        maxWidth: root.maxWidth

        text: root.finalThirdText
        
        scrollingEnabled: root.scrollingEnabled
        scrollResetOnPause: root.scrollingResetOnPause
        textColor: root.color
        forcePauseScrolling: root.forcePauseScrolling
        Layout.alignment: root.textAlignment
    }
}