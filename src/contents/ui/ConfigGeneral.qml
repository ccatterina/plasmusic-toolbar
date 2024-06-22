import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils as KCM
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.private.mpris as Mpris


KCM.SimpleKCM {
    id: configPage
    Layout.preferredWidth: form.implicitWidth;

    property alias cfg_panelIcon: panelIcon.value
    property alias cfg_useAlbumCoverAsPanelIcon: useAlbumCoverAsPanelIcon.checked
    property alias cfg_albumCoverRadius: albumCoverRadius.value
    property alias cfg_commandsInPanel: commandsInPanel.checked
    property alias cfg_maxSongWidthInPanel: maxSongWidthInPanel.value
    property alias cfg_textScrollingSpeed: textScrollingSpeed.value
    property alias cfg_separateText: separateText.checked
    property alias cfg_textScrollingBehaviour: scrollingBehaviourRadio.value
    property alias cfg_textScrollingEnabled: textScrollingEnabledCheckbox.checked
    property alias cfg_textScrollingResetOnPause: textScrollingResetOnPauseCheckbox.checked
    property alias cfg_choosePlayerAutomatically: choosePlayerAutomatically.checked

    property string cfg_preferredPlayerIdentity

    property alias cfg_useCustomFont: customFontCheckbox.checked
    property alias cfg_customFont: fontDialog.fontChosen
    property alias cfg_volumeStep: volumeStepSpinbox.value


    Kirigami.FormLayout {
        id: form

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Panel icon"
        }

        ConfigIcon {
            id: panelIcon
            Kirigami.FormData.label: i18n("Icon:")
        }

        CheckBox {
            id: useAlbumCoverAsPanelIcon
            Kirigami.FormData.label: i18n("Use album cover as panel icon")
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
            Kirigami.FormData.label: "Playback source"
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
                toolTipText: i18n("The player will be chosen automatically based on the currently playing song. If two or more players are playing at the same time, the widget will choose the one that started playing first.")
            }
        }

        RowLayout {
            RadioButton {
                id: selectPreferredPlayer
                ButtonGroup.group: playerSourceRadio
                text: i18n("Always:")
            }

            ComboBox {
                enabled: selectPreferredPlayer.checked
                id: playerComboBox
                model: sources
                onCurrentIndexChanged: {
                    configPage.cfg_preferredPlayerIdentity = model.get(currentIndex)?.text || ""
                }
            }

            Button {
                enabled: selectPreferredPlayer.checked
                icon.name: 'refreshstructure'
                onClicked: sources.reload()
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Always display information from the selected player, if it's not running the widget will be hidden. In the dropdown you can choose between all the players that are currently running, if you can't find the one you want, open the player appliacation and reload the list with reload button.")
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Song text customization"
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
            Kirigami.FormData.label: "Playback controls"
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


    ListModel {
        property var mpris2Model: Mpris.Mpris2Model {}

        id: sources
        function reload() {
            sources.clear()
            if (cfg_preferredPlayerIdentity) {
                sources.append({ "text": cfg_preferredPlayerIdentity })
            }

            const CONTAINER_ROLE = Qt.UserRole + 1
            for (var i = 1; i < mpris2Model.rowCount(); i++) {
                const player = mpris2Model.data(mpris2Model.index(i, 0), CONTAINER_ROLE)
                if (player.identity !== cfg_preferredPlayerIdentity) {
                    sources.append({ "text": player.identity })
                }
            }
        }
        Component.onCompleted: reload()
    }
}