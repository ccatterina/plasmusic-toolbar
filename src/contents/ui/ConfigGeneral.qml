import QtQuick 2.0
import QtQuick.Controls 2.5
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import QtQuick.Layouts 1.15

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_panelIcon: panelIcon.value
    property alias cfg_useAlbumCoverAsPanelIcon: useAlbumCoverAsPanelIcon.checked
    property alias cfg_albumCoverRadius: albumCoverRadius.value
    property alias cfg_commandsInPanel: commandsInPanel.checked
    property alias cfg_maxSongWidthInPanel: maxSongWidthInPanel.value
    property alias cfg_sourceIndex: sourceComboBox.currentIndex
    property alias cfg_sources: sourceComboBox.model
    property alias cfg_textScrollingSpeed: textScrollingSpeed.value
    property alias cfg_separateText: separateText.checked
    property alias cfg_textScrollingBehaviour: scrollingBehaviourRadio.value

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Panel icon"
        }

        ConfigIcon {
            id: panelIcon
            Kirigami.FormData.label: i18n("Choose icon:")
        }

        CheckBox {
            id: useAlbumCoverAsPanelIcon
            Kirigami.FormData.label: i18n("Album cover:")
            text: i18n("Use album cover as panel icon")
        }

        Slider {
            id: albumCoverRadius
            from: 0
            to: 25
            stepSize: 2
            Kirigami.FormData.label: i18n("Album cover radius:")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Sources"
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Song text"
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
            id: separateText
            text: i18n("Display title and artist in separate lines")
            Kirigami.FormData.label: i18n("Separate text:")
        }

        ColumnLayout {
            id: scrollingBehaviourRadio
            property int value: ScrollingText.OverflowBehaviour.AlwaysScroll

            Kirigami.FormData.label: i18n("Scrolling behaviour when song text overflows:")
            RadioButton {
                text: i18n("Always scroll")
                checked: scrollingBehaviourRadio.value == ScrollingText.OverflowBehaviour.AlwaysScroll
                onCheckedChanged: () => {
                    if (checked) {
                        scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.AlwaysScroll
                    }
                }
            }
            RadioButton {
                text: i18n("Scroll only on mouse over")
                checked: scrollingBehaviourRadio.value == ScrollingText.OverflowBehaviour.ScrollOnMouseOver
                onCheckedChanged: () => {
                    if (checked) {
                        scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.ScrollOnMouseOver
                    }
                }
            }
            RadioButton {
                text: i18n("Always scroll except on mouse over")
                checked: scrollingBehaviourRadio.value == ScrollingText.OverflowBehaviour.StopScrollOnMouseOver
                onCheckedChanged: () => {
                    if (checked) {
                        scrollingBehaviourRadio.value = ScrollingText.OverflowBehaviour.StopScrollOnMouseOver
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Music controls"
        }
        CheckBox {
            id: commandsInPanel
            text: i18n("Show music controls in the panel (play/pause/previous/next)")
            Kirigami.FormData.label: i18n("Show controls:")
        }
    }
}
