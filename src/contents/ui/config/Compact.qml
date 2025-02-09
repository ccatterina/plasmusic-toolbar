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
    property alias cfg_commandsInPanel: commandsInPanel.checked
    property alias cfg_songTextInPanel: songTextInPanel.checked
    property alias cfg_iconInPanel: iconInPanel.checked
    property alias cfg_maxSongWidthInPanel: maxSongWidthInPanel.value
    property alias cfg_songTextFixedWidth: songTextFixedWidth.value
    property alias cfg_useSongTextFixedWidth: useSongTextFixedWidth.checked
    property alias cfg_textScrollingSpeed: textScrollingSpeed.value
    property alias cfg_separateText: separateText.checked
    property alias cfg_textScrollingBehaviour: scrollingBehaviourRadio.value
    property alias cfg_textScrollingEnabled: textScrollingEnabledCheckbox.checked
    property alias cfg_textScrollingResetOnPause: textScrollingResetOnPauseCheckbox.checked
    property alias cfg_colorsFromAlbumCover: colorsFromAlbumCover.checked
    property alias cfg_panelBackgroundRadius: panelBackgroundRadius.value
    property alias cfg_fillAvailableSpace: fillAvailableSpaceCheckbox.checked
    property alias cfg_songTextAlignment: songTextPositionRadio.value
    property alias cfg_panelIconSizeRatio: panelIconSizeRatio.value
    property alias cfg_panelControlsSizeRatio: panelControlsSizeRatio.value

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
                    "The widget fills all available width in the horizontal panel (or height in the vertical panel); " +
                    "the icon is aligned to the left (or top) and the playback controls are aligned to " +
                    "the right (or bottom); The song text can be positioned based on user preference."
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

        CheckBox {
            id: iconInPanel
            Kirigami.FormData.label: i18n("Show icon:")
        }

        CheckBox {
            id: songTextInPanel
            Kirigami.FormData.label: i18n("Show song text:")
        }

        CheckBox {
            id: commandsInPanel
            Kirigami.FormData.label: i18n("Show playback controls:")
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
            to: 0.95
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


        CheckBox {
            id: separateText
            Kirigami.FormData.label: i18n("Title and artist in separate lines")
        }

        CheckBox {
            id: useSongTextFixedWidth
            enabled: songTextInPanel.checked && fillAvailableSpaceCheckbox
            Kirigami.FormData.label: i18n("Use fixed width:")
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
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Text scrolling"
        }

        CheckBox {
            id: textScrollingEnabledCheckbox
            Kirigami.FormData.label: i18n("Enabled:")
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Playback controls customization")
        }

        Slider {
            Layout.preferredWidth: 10 * Kirigami.Units.gridUnit
            id: panelControlsSizeRatio
            from: 0.6
            to: 0.95
            stepSize: 0.05
            Kirigami.FormData.label: i18n("Size:")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Background")
        }

        CheckBox {
            id: colorsFromAlbumCover
            enabled: useAlbumCoverAsPanelIcon.checked
            Kirigami.FormData.label: i18n("Colors from album cover")
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
}
