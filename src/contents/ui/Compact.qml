import "./components"
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris


Item {
    id: compact
    readonly property bool horizontal: widget.formFactor === PlasmaCore.Types.Horizontal
    readonly property bool fillAvailableSpace: plasmoid.configuration.fillAvailableSpace
    readonly property bool colorsFromAlbumCover: plasmoid.configuration.colorsFromAlbumCover
    readonly property int backgroundRadius: plasmoid.configuration.panelBackgroundRadius
    readonly property string panelIcon: plasmoid.configuration.panelIcon
    readonly property int albumCoverRadius: plasmoid.configuration.albumCoverRadius
    readonly property bool fallbackToIconWhenArtNotAvailable: plasmoid.configuration.fallbackToIconWhenArtNotAvailable
    readonly property bool useAlbumCoverAsPanelIcon: plasmoid.configuration.useAlbumCoverAsPanelIcon
    readonly property int songTextMaxWidth: plasmoid.configuration.maxSongWidthInPanel
    readonly property int songTextAlignment: plasmoid.configuration.songTextAlignment
    readonly property bool splitSongAndArtists: plasmoid.configuration.separateText
    readonly property int songTextScrollingBehaviour: plasmoid.configuration.textScrollingBehaviour
    readonly property int songTextScrollingSpeed: plasmoid.configuration.textScrollingSpeed
    readonly property bool songTextScrollingResetOnPause: plasmoid.configuration.textScrollingResetOnPause
    readonly property bool songTextScrollingEnabled: plasmoid.configuration.textScrollingEnabled
    readonly property font songTextFont: textFont
    readonly property font songTextBoldFont: boldTextFont
    readonly property bool showCommands: plasmoid.configuration.commandsInPanel
    readonly property real volumeStep: plasmoid.configuration.volumeStep

    property color imageColor: Kirigami.Theme.textColor
    property bool imageReady: false
    property string backgroundColor: imageReady && colorsFromAlbumCover ? Kirigami.ColorUtils.tintWithAlpha(imageColor, "#000000", 0.5) : "transparent"
    property string foregroundColor: imageReady && colorsFromAlbumCover ? Kirigami.ColorUtils.tintWithAlpha(imageColor, contrastColor, .6) : Kirigami.Theme.textColor
    property string contrastColor: Kirigami.ColorUtils.brightnessForColor(backgroundColor) === Kirigami.ColorUtils.Dark ? "#ffffff" : "#000000"

    readonly property int widgetThickness: Math.min(height, width)
    readonly property int controlsSize: Math.round(widgetThickness * 0.75)
    readonly property int lengthMargin: Math.round((widgetThickness - controlsSize))

    Layout.preferredWidth: grid.implicitWidth
    Layout.preferredHeight: grid.implicitHeight
    Layout.fillHeight: horizontal || fillAvailableSpace
    Layout.fillWidth: !horizontal || fillAvailableSpace

    Behavior on backgroundColor {
        ColorAnimation {
            duration: Kirigami.Units.longDuration
        }
    }

    Behavior on foregroundColor {
        ColorAnimation {
            duration: Kirigami.Units.longDuration
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            widget.expanded = !widget.expanded;
        }
    }

    MouseAreaWithWheelHandler {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton
        propagateComposedEvents: true
        property int wheelDelta: 0
        onClicked: (mouse) => {
            switch (mouse.button) {
            case Qt.MiddleButton:
                player.playPause()
                break
            case Qt.BackButton:
                if (player.canGoPrevious) {
                    player.previous();
                }
                break
            case Qt.ForwardButton:
                if (player.canGoNext) {
                    player.next();
                }
                break
            default:
                if (mouse.modifiers & Qt.ControlModifier) {
                    if (player.canRaise) player.raise()
                } else {
                    mouse.accepted = false
                }
            }
        }
        onWheelUp: {
            player.changeVolume(volumeStep / 100, true);
        }
        onWheelDown: {
            player.changeVolume(-volumeStep / 100, true);
        }
        z: 999
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        radius: backgroundRadius
    }

    GridLayout {
        id: grid
        columnSpacing: Kirigami.Units.smallSpacing
        rowSpacing: Kirigami.Units.smallSpacing
        columns: horizontal ? grid.children.length : 1
        rows: horizontal ? 1 : grid.children.length
        anchors.fill: parent

        PanelIcon {
            Layout.leftMargin: horizontal ? lengthMargin / 2: 0
            Layout.topMargin: horizontal ? 0 : lengthMargin / 2
            Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

            size: compact.controlsSize
            icon: panelIcon
            imageUrl: player.artUrl
            imageRadius: albumCoverRadius
            fallbackToIconWhenImageNotAvailable: fallbackToIconWhenArtNotAvailable
            type: {
                if (!useAlbumCoverAsPanelIcon) {
                    return PanelIcon.Type.Icon;
                }
                return PanelIcon.Type.Image;
            }
            onTypeChanged: {
                compact.imageReady = type === PanelIcon.Type.Image && imageReady
            }
            onImageColorChanged: (color) => {
                compact.imageColor = color
            }
            onImageReadyChanged: {
                if (type === PanelIcon.Type.Image)
                compact.imageReady = imageReady
            }
        }

        Item {
            id: middleSpace
            implicitWidth: horizontal ? panelScrollingText.implicitWidth : panelScrollingText.implicitHeight
            implicitHeight: horizontal ? panelScrollingText.implicitHeight : panelScrollingText.implicitWidth
            Layout.fillHeight: horizontal || fillAvailableSpace
            Layout.fillWidth: !horizontal || fillAvailableSpace
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.rightMargin: horizontal ? Kirigami.Units.smallSpacing : 0
            Layout.leftMargin: horizontal ? Kirigami.Units.smallSpacing : 0
            Layout.topMargin: horizontal ? 0 : Kirigami.Units.smallSpacing
            Layout.bottomMargin: horizontal ? 0: Kirigami.Units.smallSpacings
            readonly property int length: horizontal ? width : height

            ColumnLayout {
                id: panelScrollingText

                // The components are anchored before they are rotated. This means that when the widget is placed on a vertical panel
                // and the state is `vertical-top` or `vertical-bottom`, the song text may overlap with the PanelIcon or the ToolButtons.
                // As a workaround, the component's height is set equal to its width.
                height: width
                visible: songTextMaxWidth !== 0
                rotation: {
                    if (horizontal) return 0
                    if (widget.location === PlasmaCore.Types.LeftEdge) return -90
                    if (widget.location === PlasmaCore.Types.RightEdge) return 90
                }

                state: {
                    if (songTextAlignment == Qt.AlignCenter || !fillAvailableSpace) {
                        return 'centered'
                    }
                    if (horizontal && songTextAlignment == Qt.AlignLeft) {
                        return 'horizontal-left'
                    }
                    if (horizontal && songTextAlignment == Qt.AlignRight) {
                        return 'horizontal-right'
                    }
                    if (!horizontal && songTextAlignment == Qt.AlignLeft) {
                        return 'vertical-top'
                    }
                    if (!horizontal && songTextAlignment == Qt.AlignRight) {
                        return 'vertical-bottom'
                    }
                }

                states: [
                    State {
                        name: "centered"
                        AnchorChanges {
                            target: panelScrollingText
                            anchors.horizontalCenter: middleSpace.horizontalCenter
                            anchors.verticalCenter: middleSpace.verticalCenter
                        }
                    },
                    State {
                        name: "horizontal-left"
                        AnchorChanges {
                            target: panelScrollingText
                            anchors.left: middleSpace.left
                            anchors.verticalCenter: middleSpace.verticalCenter
                        }
                    },
                    State {
                        name: "horizontal-right"
                        AnchorChanges {
                            target: panelScrollingText
                            anchors.right: middleSpace.right
                            anchors.verticalCenter: middleSpace.verticalCenter
                        }
                    },
                    State {
                        name: "vertical-top"
                        AnchorChanges {
                            target: panelScrollingText
                            anchors.top: middleSpace.top
                            anchors.horizontalCenter: middleSpace.horizontalCenter
                        }
                    },
                    State {
                        name: "vertical-bottom"
                        AnchorChanges {
                            target: panelScrollingText
                            anchors.bottom: middleSpace.bottom
                            anchors.horizontalCenter: middleSpace.horizontalCenter
                        }
                    }
                ]

                ColumnLayout {
                    id: songAndArtistText
                    spacing: 0
                    anchors.centerIn: parent

                    ScrollingText {
                        visible: splitSongAndArtists
                        overflowBehaviour: songTextScrollingBehaviour
                        font: songTextBoldFont
                        speed: songTextScrollingSpeed
                        maxWidth: fillAvailableSpace ? middleSpace.length : songTextMaxWidth
                        text: player.title
                        scrollingEnabled: songTextScrollingEnabled
                        scrollResetOnPause: songTextScrollingResetOnPause
                        textColor: foregroundColor
                    }
                    ScrollingText {
                        overflowBehaviour: songTextScrollingBehaviour
                        font: songTextFont
                        speed: songTextScrollingSpeed
                        maxWidth: fillAvailableSpace ? middleSpace.length : songTextMaxWidth
                        text: splitSongAndArtists ? player.artists : [player.artists, player.title].filter((x) => x).join(" - ")
                        scrollingEnabled: songTextScrollingEnabled
                        scrollResetOnPause: songTextScrollingResetOnPause
                        visible: text.length !== 0
                        textColor: foregroundColor
                    }
                }
            }
        }

        GridLayout {
            Layout.rightMargin: horizontal ? lengthMargin / 2 : 0
            Layout.bottomMargin: horizontal ? 0: lengthMargin / 2
            columns: horizontal ? grid.children.length : 1
            rows: horizontal ? 1 : grid.children.length
            Layout.fillHeight: horizontal
            Layout.fillWidth: !horizontal
            Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

            PlasmaComponents3.ToolButton {
                visible: showCommands
                enabled: player.canGoPrevious
                icon.name: "media-skip-backward"
                icon.color: foregroundColor
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                MouseArea {
                    anchors.fill: parent
                    onClicked: player.previous()
                }
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter
            }

            PlasmaComponents3.ToolButton {
                visible: showCommands
                enabled: player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                icon.color: foregroundColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: player.playPause()
                }
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter
            }

            PlasmaComponents3.ToolButton {
                visible: showCommands
                enabled: player.canGoNext
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: "media-skip-forward"
                icon.color: foregroundColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: player.next()
                }
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter
            }
        }
    }
}