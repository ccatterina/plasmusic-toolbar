import QtQuick 2.0
import QtQuick.Controls 2.5
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_panelIcon: panelIcon.value
    property alias cfg_commandsInPanel: commandsInPanel.checked
    property alias cfg_maxSongWidthInPanel: maxSongWidthInPanel.value
    property alias cfg_sourceIndex: sourceComboBox.currentIndex
    property alias cfg_sources: sourceComboBox.model
    property alias cfg_textScrollingSpeed: textScrollingSpeed.value

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        ConfigIcon {
            id: panelIcon
            Kirigami.FormData.label: i18n("Panel icon:")
        }

        ComboBox {
            id: sourceComboBox
            editable: true

            onAccepted: () => {
                if (find(editText) === -1)
                    model = [...model, editText]
            }

            Kirigami.FormData.label: i18n("Preferred MPRIS2 source:")
        }

        SpinBox {
            id: maxSongWidthInPanel
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Panel song max width:")
        }

        Slider {
            id: textScrollingSpeed
            from: 1
            to: 10
            stepSize: 1
            Kirigami.FormData.label: i18n("Text scrolling speed:")
        }

        CheckBox {
            id: commandsInPanel
            text: "Show music controls in the panel (play/pause/previous/next)"
            Kirigami.FormData.label: i18n("Show controls:")
        }
    }
}