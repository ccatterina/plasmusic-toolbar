import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.private.mpris as Mpris


KCM.SimpleKCM {
    id: generalConfigPage

    property alias cfg_choosePlayerAutomatically: choosePlayerAutomatically.checked
    property var cfg_preferredPlayerIdentity
    property alias cfg_useCustomFont: customFontCheckbox.checked
    property alias cfg_customFont: fontDialog.fontChosen
    property alias cfg_volumeStep: volumeStepSpinbox.value

    Kirigami.FormLayout {
        id: form

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
            Kirigami.FormData.label: i18n("Font customization")
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
            Kirigami.FormData.label: i18n("Controls behaviour")
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
        parentWindow: generalConfigPage.Window.window
        property font fontChosen: Qt.font()
        onAccepted: {
            fontChosen = selectedFont
        }
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
