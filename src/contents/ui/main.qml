import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: widget

    Plasmoid.status: PlasmaCore.Types.HiddenStatus
    Plasmoid.backgroundHints: plasmoid.configuration.desktopWidgetBg
    readonly property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal

    readonly property font textFont: {
        return plasmoid.configuration.useCustomFont ? plasmoid.configuration.customFont : Kirigami.Theme.defaultFont
    }
    readonly property font boldTextFont: Qt.font(Object.assign({}, textFont, {weight: Font.Bold}))
    readonly property bool textScrollingEnabled: plasmoid.configuration.textScrollingEnabled
    readonly property bool textScrollingResetOnPause: plasmoid.configuration.textScrollingResetOnPause
    readonly property int volumeStep: plasmoid.configuration.volumeStep

    toolTipTextFormat: Text.PlainText
    toolTipMainText: player.playbackStatus > Mpris.PlaybackStatus.Stopped ? player.title : i18n("No media playing")
    toolTipSubText: {
        let text = player.artists ? i18nc("%1 is the media artist/author and %2 is the player name", "by %1 (%2)", player.artists, player.identity)
            : i18nc("%1 is the player name", "%1", player.identity)
        text += "\n" + (player.playbackStatus === Mpris.PlaybackStatus.Playing ? i18n("Middle-click to pause") : i18n("Middle-click to play"))
        text += "\n" + i18n("Scroll to adjust volume")
        text += "\n" + (player.canRaise ? i18n("Ctrl+Click to bring player to the front") : i18n("This player can't be raised"))
        return text
    }

    Player {
        id: player
        sourceIdentity: {
            if (!plasmoid.configuration.choosePlayerAutomatically) {
                return plasmoid.configuration.preferredPlayerIdentity
            }
        }
        onReadyChanged: {
          Plasmoid.status = player.ready ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
          console.debug(`Player ready changed: ${player.ready} -> plasmoid status changed: ${Plasmoid.status}`)
        }
    }

    compactRepresentation: Item {
        id: compact

        Layout.preferredWidth: grid.implicitWidth
        Layout.preferredHeight: grid.implicitHeight
        Layout.fillHeight: horizontal || plasmoid.configuration.fillAvailableSpace
        Layout.fillWidth: !horizontal || plasmoid.configuration.fillAvailableSpace
        readonly property bool colorsFromAlbumCover: plasmoid.configuration.colorsFromAlbumCover
        property color imageColor: Kirigami.Theme.textColor
        property bool imageReady: false
        property string backgroundColor: imageReady && colorsFromAlbumCover ? Kirigami.ColorUtils.tintWithAlpha(imageColor, "#000000", 0.5) : "transparent"
        property string foregroundColor: imageReady && colorsFromAlbumCover ? Kirigami.ColorUtils.tintWithAlpha(imageColor, contrastColor, .6) : Kirigami.Theme.textColor
        property string contrastColor: Kirigami.ColorUtils.brightnessForColor(backgroundColor) === Kirigami.ColorUtils.Dark ? "#ffffff" : "#000000"

        readonly property int widgetThickness: Math.min(height, width)
        readonly property int controlsSize: Math.round(widgetThickness * 0.75)
        readonly property int lengthMargin: Math.round((widgetThickness - controlsSize))

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
            radius: plasmoid.configuration.panelBackgroundRadius
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
                size: compact.controlsSize
                icon: plasmoid.configuration.panelIcon
                imageUrl: player.artUrl
                imageRadius: plasmoid.configuration.albumCoverRadius
                fallbackToIconWhenImageNotAvailable: plasmoid.configuration.fallbackToIconWhenArtNotAvailable
                type: {
                    if (!plasmoid.configuration.useAlbumCoverAsPanelIcon) {
                        return PanelIcon.Type.Icon;
                    }
                    return PanelIcon.Type.Image;
                }
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter
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
                id: panelScrollingText
                implicitWidth: horizontal ? column.implicitWidth : column.implicitHeight
                implicitHeight: horizontal ? column.implicitHeight : column.implicitWidth
                Layout.fillHeight: horizontal || plasmoid.configuration.fillAvailableSpace
                Layout.fillWidth: !horizontal || plasmoid.configuration.fillAvailableSpace
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.rightMargin: horizontal ? Kirigami.Units.smallSpacing : 0
                Layout.leftMargin: horizontal ? Kirigami.Units.smallSpacing : 0
                Layout.topMargin: horizontal ? 0 : Kirigami.Units.smallSpacing
                Layout.bottomMargin: horizontal ? 0: Kirigami.Units.smallSpacings
                readonly property int length: horizontal ? width : height

                ColumnLayout {
                    id: column
                    spacing: 0

                    // The components are anchored before they are rotated. This means that when the widget is placed on a vertical panel
                    // and the state is `vertical-top` or `vertical-bottom`, the song text may overlap with the PanelIcon or the ToolButtons.
                    // As a workaround, the component's height is set equal to its width.
                    height: width
                    visible: plasmoid.configuration.maxSongWidthInPanel !== 0
                    rotation: {
                        if (horizontal) return 0
                        if (plasmoid.location === PlasmaCore.Types.LeftEdge) return -90
                        if (plasmoid.location === PlasmaCore.Types.RightEdge) return 90
                    }

                    readonly property int songTextAlignment: plasmoid.configuration.songTextAlignment
                    state: {
                        if (songTextAlignment == Qt.AlignCenter || !plasmoid.configuration.fillAvailableSpace) {
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
                                target: column
                                anchors.horizontalCenter: panelScrollingText.horizontalCenter
                                anchors.verticalCenter: panelScrollingText.verticalCenter
                            }
                        },
                        State {
                            name: "horizontal-left"
                            AnchorChanges {
                                target: column
                                anchors.left: panelScrollingText.left
                                anchors.verticalCenter: panelScrollingText.verticalCenter
                            }
                        },
                        State {
                            name: "horizontal-right"
                            AnchorChanges {
                                target: column
                                anchors.right: panelScrollingText.right
                                anchors.verticalCenter: panelScrollingText.verticalCenter
                            }
                        },
                        State {
                            name: "vertical-top"
                            AnchorChanges {
                                target: column
                                anchors.top: panelScrollingText.top
                                anchors.horizontalCenter: panelScrollingText.horizontalCenter
                            }
                        },
                        State {
                            name: "vertical-bottom"
                            AnchorChanges {
                                target: column
                                anchors.bottom: panelScrollingText.bottom
                                anchors.horizontalCenter: panelScrollingText.horizontalCenter
                            }
                        }
                    ]

                    ColumnLayout {
                        spacing: 0
                        anchors.centerIn: parent

                        ScrollingText {
                            visible: plasmoid.configuration.separateText
                            overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                            font: widget.boldTextFont
                            speed: plasmoid.configuration.textScrollingSpeed
                            maxWidth: plasmoid.configuration.fillAvailableSpace ? panelScrollingText.length : plasmoid.configuration.maxSongWidthInPanel
                            text: player.title
                            scrollingEnabled: textScrollingEnabled
                            scrollResetOnPause: textScrollingResetOnPause
                            textColor: foregroundColor
                        }
                        ScrollingText {
                            overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                            font: widget.textFont
                            speed: plasmoid.configuration.textScrollingSpeed
                            maxWidth: plasmoid.configuration.fillAvailableSpace ? panelScrollingText.length : plasmoid.configuration.maxSongWidthInPanel
                            text: plasmoid.configuration.separateText ? player.artists : [player.artists, player.title].filter((x) => x).join(" - ")
                            scrollingEnabled: textScrollingEnabled
                            scrollResetOnPause: textScrollingResetOnPause
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
                    visible: plasmoid.configuration.commandsInPanel
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
                    visible: plasmoid.configuration.commandsInPanel
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
                    visible: plasmoid.configuration.commandsInPanel
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

    fullRepresentation: Item {
        Layout.preferredHeight: column.implicitHeight
        Layout.preferredWidth: column.implicitWidth
        Layout.minimumWidth: column.implicitWidth
        Layout.minimumHeight: column.implicitHeight

        ColumnLayout {
            id: column

            spacing: 0
            anchors.fill: parent

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                width: 300
                height: width

                Image {
                    anchors.fill: parent
                    source: player.artUrl || plasmoid.configuration.albumPlaceholder
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        id: coverMouseArea
                        anchors.fill: parent
                        cursorShape: player.canRaise ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (player.canRaise) player.raise()
                        }
                        hoverEnabled: true
                    }
                    PlasmaComponents3.ToolTip {
                        id: raisePlayerTooltip
                        anchors.centerIn: parent
                        text: player.canRaise ? i18n("Bring player to the front") : i18n("This player can't be raised")
                        visible: coverMouseArea.containsMouse
                    }
                }
            }

            TrackPositionSlider {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                songPosition: player.songPosition
                songLength: player.songLength
                playing: player.playbackStatus === Mpris.PlaybackStatus.Playing
                enableChangePosition: player.canSeek
                onRequireChangePosition: (position) => {
                    player.setPosition(position)
                }
                onRequireUpdatePosition: () => {
                    player.updatePosition()
                }
            }

            ScrollingText {
                speed: plasmoid.configuration.textScrollingSpeed
                font: widget.boldTextFont
                maxWidth: 250
                text: player.title
            }

            ScrollingText {
                speed: plasmoid.configuration.textScrollingSpeed
                font: widget.textFont
                maxWidth: 250
                text: player.artists
            }

            VolumeBar {
                Layout.leftMargin: 40
                Layout.rightMargin: 40
                Layout.topMargin: 10
                volume: player.volume
                onSetVolume: (vol) => {
                    player.setVolume(vol)
                }
                onVolumeUp: {
                    player.changeVolume(volumeStep / 100, false)
                }
                onVolumeDown: {
                    player.changeVolume(-volumeStep / 100, false)
                }
            }

            Item {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                Layout.preferredHeight: row.implicitHeight
                RowLayout {
                    id: row

                    anchors.fill: parent

                    CommandIcon {
                        enabled: player.canChangeShuffle
                        Layout.alignment: Qt.AlignHCenter
                        size: Kirigami.Units.iconSizes.medium
                        source: "media-playlist-shuffle"
                        onClicked: player.setShuffle(player.shuffle === Mpris.ShuffleStatus.Off ? Mpris.ShuffleStatus.On : Mpris.ShuffleStatus.Off)
                        active: player.shuffle === Mpris.ShuffleStatus.On
                    }

                    CommandIcon {
                        enabled: player.canGoPrevious
                        Layout.alignment: Qt.AlignHCenter
                        size: Kirigami.Units.iconSizes.medium
                        source: "media-skip-backward"
                        onClicked: player.previous()
                    }

                    CommandIcon {
                        enabled: player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                        Layout.alignment: Qt.AlignHCenter
                        size: Kirigami.Units.iconSizes.large
                        source: player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                        onClicked: player.playPause()
                    }

                    CommandIcon {
                        enabled: player.canGoNext
                        Layout.alignment: Qt.AlignHCenter
                        size: Kirigami.Units.iconSizes.medium
                        source: "media-skip-forward"
                        onClicked: player.next()
                    }

                    CommandIcon {
                        enabled: player.canChangeLoopStatus
                        Layout.alignment: Qt.AlignHCenter
                        size: Kirigami.Units.iconSizes.medium
                        source: player.loopStatus === Mpris.LoopStatus.Track ? "media-playlist-repeat-song" : "media-playlist-repeat"
                        active: player.loopStatus != Mpris.LoopStatus.None
                        onClicked: () => {
                            let status = Mpris.LoopStatus.None;
                            if (player.loopStatus == Mpris.LoopStatus.None)
                                status = Mpris.LoopStatus.Track;
                            else if (player.loopStatus === Mpris.LoopStatus.Track)
                                status = Mpris.LoopStatus.Playlist;
                            player.setLoopStatus(status);
                        }
                    }

                }

            }

        }
    }
}
