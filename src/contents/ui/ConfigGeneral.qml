import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils as KCM
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mpris as Mpris


KCM.SimpleKCM {
    id: configPage
    Layout.preferredWidth: form.implicitWidth;

    property alias cfg_panelIcon: panelIcon.value
    property alias cfg_useAlbumCoverAsPanelIcon: useAlbumCoverAsPanelIcon.checked
    property alias cfg_fallbackToIconWhenArtNotAvailable: fallbackToIconWhenArtNotAvailable.checked
    property alias cfg_albumCoverRadius: albumCoverRadius.value
    property alias cfg_commandsInPanel: commandsInPanel.checked
    property alias cfg_maxSongWidthInPanel: maxSongWidthInPanel.value
    property alias cfg_textScrollingSpeed: textScrollingSpeed.value
    property alias cfg_separateText: separateText.checked
    property alias cfg_textScrollingBehaviour: scrollingBehaviourRadio.value
    property alias cfg_textScrollingEnabled: textScrollingEnabledCheckbox.checked
    property alias cfg_textScrollingResetOnPause: textScrollingResetOnPauseCheckbox.checked
    property alias cfg_choosePlayerAutomatically: choosePlayerAutomatically.checked
    property var cfg_preferredPlayerIdentity
    property alias cfg_useCustomFont: customFontCheckbox.checked
    property alias cfg_customFont: fontDialog.fontChosen
    property alias cfg_volumeStep: volumeStepSpinbox.value
    property alias cfg_desktopWidgetBg: desktopWidgetBackgroundRadio.value
    property alias cfg_albumPlaceholder: albumPlaceholderDialog.value
    property alias cfg_colorsFromAlbumCover: colorsFromAlbumCover.checked
    property alias cfg_panelBackgroundRadius: panelBackgroundRadius.value
    property alias cfg_fillAvailableSpace: fillAvailableSpaceCheckbox.checked
    property alias cfg_songTextAlignment: songTextPositionRadio.value

    Kirigami.FormLayout {
        id: form

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Panel view layout")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fill available space")
            CheckBox {
                id: fillAvailableSpaceCheckbox
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "The widget fill all available width (if placed in horizontal panel, height otherwise) in the panel, " +
                    "the panel icon is aligned to the left (or top) and the playback controls are aligned to the right (or bottom). " +
                    "The song text can be positioned based on user preference."
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
            enabled: fillAvailableSpaceCheckbox.checked
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
            enabled: fillAvailableSpaceCheckbox.checked
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
            enabled: fillAvailableSpaceCheckbox.checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Panel icon")
        }

        ConfigIcon {
            id: panelIcon
            Kirigami.FormData.label: i18n("Icon:")
        }

        CheckBox {
            id: useAlbumCoverAsPanelIcon
            Kirigami.FormData.label: i18n("Use album cover as panel icon")
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
            Kirigami.FormData.label: i18n("Playback source")
        }

        ButtonGroup {
            id: playerSourceRadio
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Player:")
            RadioButton {
                id: choosePlayerAutomatically
                text: i18n("Choose automatically")
                ButtonGroup.group: playerSourceRadio
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "The player will be chosen automatically based on the currently playing song." +
                    "If two or more players are playing at the same time, the widget will choose " +
                    "the one that started playing first."
                )
            }
        }

        RowLayout {
            RadioButton {
                id: selectPreferredPlayer
                text: i18n("Always:")
                checked: !choosePlayerAutomatically.checked
                ButtonGroup.group: playerSourceRadio
            }

            ComboBox {
                enabled: selectPreferredPlayer.checked
                id: playerComboBox
                model: sources
                Component.onCompleted: {
                    const preferredPlayerIndex = playerComboBox.find(cfg_preferredPlayerIdentity)
                    playerComboBox.currentIndex = preferredPlayerIndex != -1 ? preferredPlayerIndex : 0
                }
                onCurrentValueChanged: {
                    if (currentValue) {
                        cfg_preferredPlayerIdentity = currentValue
                    }
                }
            }

            Button {
                enabled: selectPreferredPlayer.checked
                icon.name: 'refreshstructure'
                onClicked: {
                    sources.reload(cfg_preferredPlayerIdentity)
                    const preferredPlayerIndex = playerComboBox.find(cfg_preferredPlayerIdentity)
                    playerComboBox.currentIndex = preferredPlayerIndex != -1 ? preferredPlayerIndex : 0
                }
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "Always display information from the selected player, if it's not running the widget " +
                    "will be hidden. In the dropdown you can choose between all the players that are currently " +
                    "running, if you can't find the one you want, open the player appliacation and reload " +
                    "the list with reload button."
                )
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Song text customization")
        }

        SpinBox {
            id: maxSongWidthInPanel
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Panel song max width:")
        }

        CheckBox {
            id: separateText
            Kirigami.FormData.label: i18n("Title and artist in separate lines")
        }

        CheckBox {
            id: textScrollingEnabledCheckbox
            Kirigami.FormData.label: i18n("Text scrolling:")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            id: textScrollingSpeed
            from: 1
            to: 10
            stepSize: 1
            Kirigami.FormData.label: i18n("Text scrolling speed:")
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
                    scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.AlwaysScroll
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
                    scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.ScrollOnMouseOver
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
                    scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.StopScrollOnMouseOver
                }
            }
            ButtonGroup.group: scrollingBehaviourRadio
            enabled: textScrollingEnabledCheckbox.checked
        }

        CheckBox {
            id: textScrollingResetOnPauseCheckbox
            Kirigami.FormData.label: i18n("Reset position when scrolling is paused:")
            enabled: textScrollingEnabledCheckbox.checked
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Custom font:")

            CheckBox {
                id: customFontCheckbox
            }

            Button {
                text: i18n("Choose…")
                icon.name: "settings-configure"
                enabled: customFontCheckbox.checked
                onClicked: {
                    fontDialog.open()
                }
            }
        }

        Label {
            visible: customFontCheckbox.checked && fontDialog.fontChosen.family && fontDialog.fontChosen.pointSize
            text: i18n("%1pt %2", fontDialog.fontChosen.pointSize, fontDialog.fontChosen.family)
            textFormat: Text.PlainText
            font: fontDialog.fontChosen
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Playback controls")
        }

        CheckBox {
            id: commandsInPanel
            Kirigami.FormData.label: i18n("Playback controls in the panel")
        }

        SpinBox {
            id: volumeStepSpinbox
            Kirigami.FormData.label: i18n("Volume step:")
            from: 1
            to: 100
            textFromValue: function(text) { return text + "%"; }
            valueFromText: function(value) { return parseInt(value); }
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
            Kirigami.FormData.label: i18n("Background")
        }

        ButtonGroup {
            id: desktopWidgetBackgroundRadio
            property int value: PlasmaCore.Types.StandardBackground
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Background (only for desktop applet):")
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
                    "The applet won't have a background but a drop shadow of " +
                    "its content done via a shader. The text color will also invert."
                )
            }
        }

        CheckBox {
            id: colorsFromAlbumCover
            Kirigami.FormData.label: i18n("Colors from album cover (only for panel applet)")
            enabled: useAlbumCoverAsPanelIcon.checked
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            enabled: colorsFromAlbumCover.checked
            id: panelBackgroundRadius
            from: 0
            to: 25
            stepSize: 2
            Kirigami.FormData.label: i18n("Colored background radius:")
        }
    }

    QtDialogs.FontDialog {
        id: fontDialog
        title: i18n("Choose a Font")
        modality: Qt.WindowModal
        parentWindow: configPage.Window.window
        property font fontChosen: Qt.font()
        onAccepted: {
            fontChosen = selectedFont
        }
    }

    QtDialogs.FileDialog {
        id: albumPlaceholderDialog
        property var value: null
        onAccepted: value = selectedFile
    }

    ListModel {
        property var mpris2Model: Mpris.Mpris2Model {}

        id: sources
        function reload(predefinedSource) {
            sources.clear()
            if (predefinedSource) {
                sources.append({ "text": predefinedSource })
            }

            const CONTAINER_ROLE = Qt.UserRole + 1
            for (var i = 1; i < mpris2Model.rowCount(); i++) {
                const player = mpris2Model.data(mpris2Model.index(i, 0), CONTAINER_ROLE)
                if (predefinedSource !== player.identity) {
                    sources.append({ "text": player.identity })
                }
            }
        }
        Component.onCompleted: reload(cfg_preferredPlayerIdentity)
    }
}
