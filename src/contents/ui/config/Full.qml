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

    Kirigami.FormLayout {
        id: form

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
