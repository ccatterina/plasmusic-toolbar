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
            Kirigami.FormData.label: "Song Text scrolling"
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
            Kirigami.FormData.label: i18n("Background (desktop widget only)")
        }

        ButtonGroup {
            id: desktopWidgetBackgroundRadio
            property int value: PlasmaCore.Types.StandardBackground
        }

        RowLayout {
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
    }

    QtDialogs.FileDialog {
        id: albumPlaceholderDialog
        property var value: null
        onAccepted: value = selectedFile
    }
}
