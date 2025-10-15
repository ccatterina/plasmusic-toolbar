import "../components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM


KCM.SimpleKCM {
    id: compactConfigPage
    Layout.preferredWidth: form.implicitWidth;

    property alias cfg_panelIcon: panelIcon.value
    property alias cfg_useAlbumCoverAsPanelIcon: useAlbumCoverAsPanelIcon.checked
    property alias cfg_fallbackToIconWhenArtNotAvailable: fallbackToIconWhenArtNotAvailable.checked
    property alias cfg_albumCoverRadius: albumCoverRadius.value
    property alias cfg_skipBackwardControlInPanel: skipBackwardControlInPanel.checked
    property alias cfg_playPauseControlInPanel: playPauseControlInPanel.checked
    property alias cfg_skipForwardControlInPanel: skipForwardControlInPanel.checked
    property alias cfg_songTextInPanel: songTextInPanel.checked
    property alias cfg_iconInPanel: iconInPanel.checked
    property alias cfg_maxSongWidthInPanel: maxSongWidthInPanel.value
    property alias cfg_songTextFixedWidth: songTextFixedWidth.value
    property alias cfg_useSongTextFixedWidth: useSongTextFixedWidth.checked
    property alias cfg_textScrollingSpeed: textScrollingSpeed.value
    property alias cfg_textScrollingBehaviour: scrollingBehaviourRadio.value
    property alias cfg_pauseTextScrollingWhileMediaIsNotPlaying: pauseWhileMediaIsNotPlaying.checked
    property alias cfg_textScrollingEnabled: textScrollingEnabledCheckbox.checked
    property alias cfg_textScrollingResetOnPause: textScrollingResetOnPauseCheckbox.checked
    property alias cfg_colorsFromAlbumCover: colorsFromAlbumCover.checked
    property alias cfg_panelBackgroundRadius: panelBackgroundRadius.value
    property alias cfg_fillAvailableSpace: fillAvailableSpaceCheckbox.checked
    property alias cfg_songTextAlignment: songTextPositionRadio.value
    property alias cfg_panelIconSizeRatio: panelIconSizeRatio.value
    property alias cfg_panelControlsSizeRatio: panelControlsSizeRatio.value
    property alias cfg_spaceBetweenControlsInPanel: spaceBetweenControlsInPanel.checked
    property alias cfg_artistsPosition: artistsPosition.value
    property alias cfg_titlePosition: titlePosition.value
    property alias cfg_albumPosition: albumPosition.value
    property alias cfg_compactTruncatedTextStyle: compactTruncatedTextStyle.value
    property alias cfg_mediaProgressInPanel: mediaProgressInPanel.checked

    Kirigami.FormLayout {
        id: form

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Layout")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fill available space in the panel")
            CheckBox {
                id: fillAvailableSpaceCheckbox
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "The widget fills all available width in the horizontal panel (or height in the vertical panel);  the icon is aligned to the left (or top) and the playback controls are aligned to the right (or bottom); The song text can be positioned based on user preference."
                )
            }
        }

        ButtonGroup {
            id: songTextPositionRadio
            property int value: Qt.AlignLeft
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Song text alignment:")
            text: i18n("Left (Top for vertical panel)")
            checked: songTextPositionRadio.value == Qt.AlignLeft
            onCheckedChanged: () => {
                if (checked) {
                    songTextPositionRadio.value = Qt.AlignLeft
                }
            }
            ButtonGroup.group: songTextPositionRadio
        }

        RadioButton {
            text: i18n("Center")
            checked: songTextPositionRadio.value == Qt.AlignCenter
            onCheckedChanged: () => {
                if (checked) {
                    songTextPositionRadio.value = Qt.AlignCenter
                }
            }
            ButtonGroup.group: songTextPositionRadio
        }

        RadioButton {
            text: i18n("Right (Bottom for vertical panel)")
            checked: songTextPositionRadio.value == Qt.AlignRight
            onCheckedChanged: () => {
                if (checked) {
                    songTextPositionRadio.value = Qt.AlignRight
                }
            }
            ButtonGroup.group: songTextPositionRadio
        }

        CheckBox {
            id: iconInPanel
            Kirigami.FormData.label: i18n("Show icon:")
        }

        CheckBox {
            id: songTextInPanel
            Kirigami.FormData.label: i18n("Show song text")
        }

        CheckBox {
            id: skipBackwardControlInPanel
            Kirigami.FormData.label: i18n("Show skip backward control")
        }

        CheckBox {
            id: playPauseControlInPanel
            Kirigami.FormData.label: i18n("Show play/pause control")
        }

        CheckBox {
            id: skipForwardControlInPanel
            Kirigami.FormData.label: i18n("Show skip forward control")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Icon customization")
        }

        ConfigIcon {
            id: panelIcon
            Kirigami.FormData.label: i18n("Icon:")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            id: panelIconSizeRatio
            from: 0.6
            to: 1
            stepSize: 0.05
            Kirigami.FormData.label: i18n("Size:")
        }

        CheckBox {
            id: useAlbumCoverAsPanelIcon
            Kirigami.FormData.label: i18n("Use album cover as icon")
        }

        CheckBox {
            id: fallbackToIconWhenArtNotAvailable
            enabled: useAlbumCoverAsPanelIcon.checked
            Kirigami.FormData.label: i18n("Fallback to icon if cover is not available")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            enabled: useAlbumCoverAsPanelIcon.checked
            id: albumCoverRadius
            from: 0
            to: 25
            stepSize: 2
            Kirigami.FormData.label: i18n("Album cover radius:")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Song text customization")
        }

        // group for title

        ButtonGroup {
            id: titlePosition
            property int value: SongAndArtistText.TextPosition.FirstLine
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Song title position:")
            text: i18n("Hidden")
            checked: titlePosition.value == SongAndArtistText.TextPosition.Hidden
            onCheckedChanged: () => {
                if (checked) {
                    titlePosition.value = SongAndArtistText.TextPosition.Hidden
                }
            }
            ButtonGroup.group: titlePosition
        }

        RadioButton {
            text: i18n("First line")
            checked: titlePosition.value == SongAndArtistText.TextPosition.FirstLine
            onCheckedChanged: () => {
                if (checked) {
                    titlePosition.value = SongAndArtistText.TextPosition.FirstLine
                }
            }
            ButtonGroup.group: titlePosition
        }

        RadioButton {
            text: i18n("Second line")
            checked: titlePosition.value == SongAndArtistText.TextPosition.SecondLine
            onCheckedChanged: () => {
                if (checked) {
                    titlePosition.value = SongAndArtistText.TextPosition.SecondLine
                }
            }
            ButtonGroup.group: titlePosition
        }


        // group for artists

        Item {
            // adds spacing between the groups
            height: 0.5 * Kirigami.Units.gridUnit
        }

        ButtonGroup {
            id: artistsPosition
            property int value: SongAndArtistText.TextPosition.FirstLine
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Artists position:")
            text: i18n("Hidden")
            checked: artistsPosition.value == SongAndArtistText.TextPosition.Hidden
            onCheckedChanged: () => {
                if (checked) {
                    artistsPosition.value = SongAndArtistText.TextPosition.Hidden
                }
            }
            ButtonGroup.group: artistsPosition
        }

        RadioButton {
            text: i18n("First line")
            checked: artistsPosition.value == SongAndArtistText.TextPosition.FirstLine
            onCheckedChanged: () => {
                if (checked) {
                    artistsPosition.value = SongAndArtistText.TextPosition.FirstLine
                }
            }
            ButtonGroup.group: artistsPosition
        }

        RadioButton {
            text: i18n("Second line")
            checked: artistsPosition.value == SongAndArtistText.TextPosition.SecondLine
            onCheckedChanged: () => {
                if (checked) {
                    artistsPosition.value = SongAndArtistText.TextPosition.SecondLine
                }
            }
            ButtonGroup.group: artistsPosition
        }

        // group for album
        Item {
            // adds spacing between the groups
            height: 0.5 * Kirigami.Units.gridUnit
        }

        ButtonGroup {
            id: albumPosition
            property int value: SongAndArtistText.TextPosition.Hidden
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Album title position:")
            text: i18n("Hidden")
            checked: albumPosition.value == SongAndArtistText.TextPosition.Hidden
            onCheckedChanged: () => {
                if (checked) {
                    albumPosition.value = SongAndArtistText.TextPosition.Hidden
                }
            }
            ButtonGroup.group: albumPosition
        }

        RadioButton {
            text: i18n("First line")
            checked: albumPosition.value == SongAndArtistText.TextPosition.FirstLine
            onCheckedChanged: () => {
                if (checked) {
                    albumPosition.value = SongAndArtistText.TextPosition.FirstLine
                }
            }
            ButtonGroup.group: albumPosition
        }

        RadioButton {
            text: i18n("Second line")
            checked: albumPosition.value == SongAndArtistText.TextPosition.SecondLine
            onCheckedChanged: () => {
                if (checked) {
                    albumPosition.value = SongAndArtistText.TextPosition.SecondLine
                }
            }
            ButtonGroup.group: albumPosition
        }

        Item {
            // adds spacing between the groups
            height: 0.5 * Kirigami.Units.gridUnit
        }

        CheckBox {
            id: useSongTextFixedWidth
            enabled: songTextInPanel.checked && fillAvailableSpaceCheckbox
            Kirigami.FormData.label: i18n("Use fixed width")
        }

        SpinBox {
            id: songTextFixedWidth
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("fixed width:")
            enabled: useSongTextFixedWidth.checked && songTextInPanel.checked && fillAvailableSpaceCheckbox
        }

        SpinBox {
            id: maxSongWidthInPanel
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("max width:")
            enabled: !useSongTextFixedWidth.checked && songTextInPanel.checked && fillAvailableSpaceCheckbox
        }

        Item {
            // adds spacing between the groups
            height: 0.5 * Kirigami.Units.gridUnit
        }

        Kirigami.ContextualHelpButton {
            Kirigami.FormData.label: i18n("Truncated text style:")
            toolTipText: i18n("Works only when the text is not scrolling and in the initial position")
        }

        ButtonGroup {
            id: compactTruncatedTextStyle
            property int value: ScrollingText.TruncateStyle.FadeOut
        }

        RadioButton {
            text: i18n("Elide")
            checked: compactTruncatedTextStyle.value == ScrollingText.TruncateStyle.Elide
            onCheckedChanged: () => {
                if (checked) {
                    compactTruncatedTextStyle.value = ScrollingText.TruncateStyle.Elide
                }
            }
            ButtonGroup.group: compactTruncatedTextStyle
        }

        RadioButton {
            text: i18n("Fade out")
            checked: compactTruncatedTextStyle.value == ScrollingText.TruncateStyle.FadeOut
            onCheckedChanged: () => {
                if (checked) {
                    compactTruncatedTextStyle.value = ScrollingText.TruncateStyle.FadeOut
                }
            }
            ButtonGroup.group: compactTruncatedTextStyle
        }

        RadioButton {
            text: i18n("None")
            checked: compactTruncatedTextStyle.value == ScrollingText.TruncateStyle.None
            onCheckedChanged: () => {
                if (checked) {
                    compactTruncatedTextStyle.value = ScrollingText.TruncateStyle.None
                }
            }
            ButtonGroup.group: compactTruncatedTextStyle
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Text scrolling")
        }

        CheckBox {
            id: textScrollingEnabledCheckbox
            Kirigami.FormData.label: i18n("Enabled")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            id: textScrollingSpeed
            from: 1
            to: 10
            stepSize: 1
            Kirigami.FormData.label: i18n("Speed:")
            enabled: textScrollingEnabledCheckbox.checked
        }

        ButtonGroup {
            id: scrollingBehaviourRadio
            property int value: ScrollingText.OverflowBehaviour.AlwaysScroll
        }

        RadioButton {
            Kirigami.FormData.label: i18n("When text overflows:")
            id: alwaysScroll
            text: i18n("Always scroll")
            checked: scrollingBehaviourRadio.value == ScrollingText.OverflowBehaviour.AlwaysScroll
            onCheckedChanged: () => {
                if (checked) {
                    scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.AlwaysScroll;
                }
            }
            ButtonGroup.group: scrollingBehaviourRadio
            enabled: textScrollingEnabledCheckbox.checked
        }

        RadioButton {
            id: scrollOnMouseOver
            text: i18n("Scroll only on mouse over")
            checked: scrollingBehaviourRadio.value == ScrollingText.OverflowBehaviour.ScrollOnMouseOver
            onCheckedChanged: () => {
                if (checked) {
                    scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.ScrollOnMouseOver;
                }
            }
            ButtonGroup.group: scrollingBehaviourRadio
            enabled: textScrollingEnabledCheckbox.checked
        }

        RadioButton {
            id: stopOnMouseOver
            text: i18n("Always scroll except on mouse over")
            checked: scrollingBehaviourRadio.value == ScrollingText.OverflowBehaviour.StopScrollOnMouseOver
            onCheckedChanged: () => {
                if (checked) {
                    scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.StopScrollOnMouseOver;
                }
            }
            ButtonGroup.group: scrollingBehaviourRadio
            enabled: textScrollingEnabledCheckbox.checked
        }

        CheckBox {
            id: pauseWhileMediaIsNotPlaying
            Kirigami.FormData.label: i18n("Pause scrolling while media is not playing")
        }

        CheckBox {
            id: textScrollingResetOnPauseCheckbox
            Kirigami.FormData.label: i18n("Reset position when scrolling is paused")
            enabled: textScrollingEnabledCheckbox.checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Playback controls customization")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            id: panelControlsSizeRatio
            from: 0.6
            to: 1.1
            stepSize: 0.05
            Kirigami.FormData.label: i18n("Size:")
        }
        CheckBox {
            id: spaceBetweenControlsInPanel
            Kirigami.FormData.label: i18n("Space between controls")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Background")
        }

        CheckBox {
            id: mediaProgressInPanel
            Kirigami.FormData.label: i18n("Media progress")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Colors from album cover")
            enabled: useAlbumCoverAsPanelIcon.checked

            CheckBox {
                id: colorsFromAlbumCover
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Use album cover as icon should be checked for background to work.")
            }
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            enabled: colorsFromAlbumCover.checked || mediaProgressInPanel.checked
            id: panelBackgroundRadius
            from: 0
            to: 25
            stepSize: 2
            Kirigami.FormData.label: i18n("Background radius:")
        }
    }
}
