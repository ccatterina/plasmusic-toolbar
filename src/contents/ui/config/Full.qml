import "../components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.core as PlasmaCore


KCM.SimpleKCM {
    id: fullConfigPage
    Layout.preferredWidth: form.implicitWidth;

    property alias cfg_desktopWidgetBg: desktopWidgetBackgroundRadio.value
    property alias cfg_albumPlaceholder: albumPlaceholderDialog.value
    property alias cfg_fullViewTextScrollingSpeed: fullViewTextScrollingSpeed.value
    property alias cfg_fullArtistsPosition: fullArtistsPosition.value
    property alias cfg_fullTitlePosition: fullTitlePosition.value
    property alias cfg_fullAlbumPosition: fullAlbumPosition.value
    property alias cfg_fullAlbumCoverAsBackground: fullAlbumCoverAsBackground.checked
    property alias cfg_fullViewThumbnailVisible: fullViewThumbnailVisible.checked
    property alias cfg_fullViewProgressBarVisible: fullViewProgressBarVisible.checked
    property alias cfg_fullViewVolumeControlVisible: fullViewVolumeControlVisible.checked
    property alias cfg_fullViewShuffleVisible: fullViewShuffleVisible.checked
    property alias cfg_fullViewPlaybackControlsVisible: fullViewPlaybackControlsVisible.checked
    property alias cfg_fullViewLoopVisible: fullViewLoopVisible.checked
    property alias cfg_fullViewPlaybackControlsFillWidth: fullViewPlaybackControlsFillWidth.checked
    property alias cfg_fullViewSongTextVisible: fullViewSongTextVisible.checked
    property alias cfg_fullViewSongTextAlignment: fullViewSongTextAlignment.value
    property alias cfg_fullViewSongTextPosition: fullViewSongTextPosition.value
    property alias cfg_fullViewMinWidth: fullViewMinWidth.value
    property alias cfg_fullViewMaxWidth: fullViewMaxWidth.value

    Kirigami.FormLayout {
        id: form

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Layout")
        }

        CheckBox {
            id: fullViewThumbnailVisible
            Kirigami.FormData.label: i18n("Show album cover")
        }

        CheckBox {
            id: fullViewProgressBarVisible
            Kirigami.FormData.label: i18n("Show progress bar")
        }

        ButtonGroup {
            id: fullViewSongTextAlignment
            property int value: Qt.AlignHCenter
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Song text alignment:")
            text: i18n("Left")
            enabled: fullViewSongTextVisible.checked
            checked: fullViewSongTextAlignment.value == Qt.AlignLeft
            onCheckedChanged: () => {
                if (checked) {
                    fullViewSongTextAlignment.value = Qt.AlignLeft
                }
            }
            ButtonGroup.group: fullViewSongTextAlignment
        }

        RadioButton {
            text: i18n("Center")
            enabled: fullViewSongTextVisible.checked
            checked: fullViewSongTextAlignment.value == Qt.AlignHCenter
            onCheckedChanged: () => {
                if (checked) {
                    fullViewSongTextAlignment.value = Qt.AlignHCenter
                }
            }
            ButtonGroup.group: fullViewSongTextAlignment
        }

        RadioButton {
            text: i18n("Right")
            enabled: fullViewSongTextVisible.checked
            checked: fullViewSongTextAlignment.value == Qt.AlignRight
            onCheckedChanged: () => {
                if (checked) {
                    fullViewSongTextAlignment.value = Qt.AlignRight
                }
            }
            ButtonGroup.group: fullViewSongTextAlignment
        }

        CheckBox {
            id: fullViewSongTextVisible
            Kirigami.FormData.label: i18n("Show song text")
        }

        ButtonGroup {
            id: fullViewSongTextPosition
            property int value: SongAndArtistText.VerticalPosition.UnderProgressBar
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Song text position:")
            text: i18n("Above progress bar")
            enabled: fullViewSongTextVisible.checked
            checked: fullViewSongTextPosition.value === SongAndArtistText.VerticalPosition.AboveProgressBar
            onCheckedChanged: () => {
                if (checked) {
                    fullViewSongTextPosition.value = SongAndArtistText.VerticalPosition.AboveProgressBar
                }
            }
            ButtonGroup.group: fullViewSongTextPosition
        }

        RadioButton {
            text: i18n("Under progress bar")
            enabled: fullViewSongTextVisible.checked
            checked: fullViewSongTextPosition.value === SongAndArtistText.VerticalPosition.UnderProgressBar
            onCheckedChanged: () => {
                if (checked) {
                    fullViewSongTextPosition.value = SongAndArtistText.VerticalPosition.UnderProgressBar
                }
            }
            ButtonGroup.group: fullViewSongTextPosition
        }

        CheckBox {
            id: fullViewVolumeControlVisible
            Kirigami.FormData.label: i18n("Show volume control")
        }

        CheckBox {
            id: fullViewShuffleVisible
            Kirigami.FormData.label: i18n("Show shuffle control")
        }

        CheckBox {
            id: fullViewPlaybackControlsVisible
            Kirigami.FormData.label: i18n("Show playback controls")
        }

        CheckBox {
            id: fullViewLoopVisible
            Kirigami.FormData.label: i18n("Show loop control")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fill available space with playback controls")
            CheckBox {
                id: fullViewPlaybackControlsFillWidth
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "When enabled, playback controls are spread across the full width of the widget. When disabled, they are grouped together in the center."
                )
            }
        }

        SpinBox {
            id: fullViewMinWidth
            Kirigami.FormData.label: i18n("Minimum resizable width:")
            from: 100
            to: fullViewMaxWidth.value
            stepSize: 10
        }

        SpinBox {
            id: fullViewMaxWidth
            Kirigami.FormData.label: i18n("Maximum resizable width:")
            from: fullViewMinWidth.value
            to: 2000
            stepSize: 10
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Album cover")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Album placeholder:")

            Button {
                text: i18n("Choose…")
                icon.name: "settings-configure"
                onClicked: {
                    albumPlaceholderDialog.open()
                }
            }

            Button {
                text: i18n("Clear")
                icon.name: "edit-delete"
                visible: albumPlaceholderDialog.value
                onClicked: {
                    albumPlaceholderDialog.value = ""
                }
            }
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: albumPlaceholderDialog.value
            Image {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                source: albumPlaceholderDialog.value
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Song Text Customization")
        }

        // group for title

        ButtonGroup {
            id: fullTitlePosition
            property int value: SongAndArtistText.TextPosition.FirstLine
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Song title position:")
            text: i18n("Hidden")
            checked: fullTitlePosition.value == SongAndArtistText.TextPosition.Hidden
            onCheckedChanged: () => {
                if (checked) {
                    fullTitlePosition.value = SongAndArtistText.TextPosition.Hidden
                }
            }
            ButtonGroup.group: fullTitlePosition
        }

        RadioButton {
            text: i18n("First line")
            checked: fullTitlePosition.value == SongAndArtistText.TextPosition.FirstLine
            onCheckedChanged: () => {
                if (checked) {
                    fullTitlePosition.value = SongAndArtistText.TextPosition.FirstLine
                }
            }
            ButtonGroup.group: fullTitlePosition
        }

        RadioButton {
            text: i18n("Second line")
            checked: fullTitlePosition.value == SongAndArtistText.TextPosition.SecondLine
            onCheckedChanged: () => {
                if (checked) {
                    fullTitlePosition.value = SongAndArtistText.TextPosition.SecondLine
                }
            }
            ButtonGroup.group: fullTitlePosition
        }


        // group for artists

        Item {
            // adds spacing between the groups
            height: 0.5 * Kirigami.Units.gridUnit
        }

        ButtonGroup {
            id: fullArtistsPosition
            property int value: SongAndArtistText.TextPosition.SecondLine
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Artists position:")
            text: i18n("Hidden")
            checked: fullArtistsPosition.value == SongAndArtistText.TextPosition.Hidden
            onCheckedChanged: () => {
                if (checked) {
                    fullArtistsPosition.value = SongAndArtistText.TextPosition.Hidden
                }
            }
            ButtonGroup.group: fullArtistsPosition
        }

        RadioButton {
            text: i18n("First line")
            checked: fullArtistsPosition.value == SongAndArtistText.TextPosition.FirstLine
            onCheckedChanged: () => {
                if (checked) {
                    fullArtistsPosition.value = SongAndArtistText.TextPosition.FirstLine
                }
            }
            ButtonGroup.group: fullArtistsPosition
        }

        RadioButton {
            text: i18n("Second line")
            checked: fullArtistsPosition.value == SongAndArtistText.TextPosition.SecondLine
            onCheckedChanged: () => {
                if (checked) {
                    fullArtistsPosition.value = SongAndArtistText.TextPosition.SecondLine
                }
            }
            ButtonGroup.group: fullArtistsPosition
        }

        // group for album
        Item {
            // adds spacing between the groups
            height: 0.5 * Kirigami.Units.gridUnit
        }

        ButtonGroup {
            id: fullAlbumPosition
            property int value: SongAndArtistText.TextPosition.SecondLine
        }

        RadioButton {
            Kirigami.FormData.label: i18n("Album title position:")
            text: i18n("Hidden")
            checked: fullAlbumPosition.value == SongAndArtistText.TextPosition.Hidden
            onCheckedChanged: () => {
                if (checked) {
                    fullAlbumPosition.value = SongAndArtistText.TextPosition.Hidden
                }
            }
            ButtonGroup.group: fullAlbumPosition
        }

        RadioButton {
            text: i18n("First line")
            checked: fullAlbumPosition.value == SongAndArtistText.TextPosition.FirstLine
            onCheckedChanged: () => {
                if (checked) {
                    fullAlbumPosition.value = SongAndArtistText.TextPosition.FirstLine
                }
            }
            ButtonGroup.group: fullAlbumPosition
        }

        RadioButton {
            text: i18n("Second line")
            checked: fullAlbumPosition.value == SongAndArtistText.TextPosition.SecondLine
            onCheckedChanged: () => {
                if (checked) {
                    fullAlbumPosition.value = SongAndArtistText.TextPosition.SecondLine
                }
            }
            ButtonGroup.group: fullAlbumPosition
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Text scrolling")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            id: fullViewTextScrollingSpeed
            from: 1
            to: 10
            stepSize: 1
            Kirigami.FormData.label: i18n("Speed:")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Background")
        }

        ButtonGroup {
            id: desktopWidgetBackgroundRadio
            property int value: PlasmaCore.Types.StandardBackground
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Background (desktop widget only):")
            RadioButton {
                text: i18n("Standard")
                checked: desktopWidgetBackgroundRadio.value == PlasmaCore.Types.StandardBackground
                onCheckedChanged: () => {
                    if (checked) {
                        desktopWidgetBackgroundRadio.value = PlasmaCore.Types.StandardBackground
                    }
                }
                ButtonGroup.group: desktopWidgetBackgroundRadio
            }
            Kirigami.ContextualHelpButton {
                toolTipText: (
                    "The standard background from the theme."
                )
            }
        }
        RadioButton {
            text: i18n("Transparent")
            checked: desktopWidgetBackgroundRadio.value == PlasmaCore.Types.NoBackground
            onCheckedChanged: () => {
                if (checked) {
                    desktopWidgetBackgroundRadio.value = PlasmaCore.Types.NoBackground
                }
            }
            ButtonGroup.group: desktopWidgetBackgroundRadio
        }
        RowLayout {
            RadioButton {
                text: i18n("Transparent (Shadow content)")
                checked: desktopWidgetBackgroundRadio.value == PlasmaCore.Types.ShadowBackground
                onCheckedChanged: () => {
                    if (checked) {
                        desktopWidgetBackgroundRadio.value = PlasmaCore.Types.ShadowBackground
                    }
                }
                ButtonGroup.group: desktopWidgetBackgroundRadio
            }
            Kirigami.ContextualHelpButton {
                toolTipText: (
                    "The applet won't have a background but a drop shadow of its content done via a shader. The text color will also invert."
                )
            }
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Use album cover as background")
            id: fullAlbumCoverAsBackground
            text: i18n("(Experimental feature)")
        }
    }

    QtDialogs.FileDialog {
        id: albumPlaceholderDialog
        property var value: null
        onAccepted: value = selectedFile
    }
}
