import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: widget

    Plasmoid.status: PlasmaCore.Types.HiddenStatus
    Plasmoid.backgroundHints: plasmoid.configuration.desktopWidgetBg

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
        sourceName: plasmoid.configuration.sources[plasmoid.configuration.sourceIndex]
        onReadyChanged: {
          Plasmoid.status = player.ready ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
          console.debug(`Player ready changed: ${player.ready} -> plasmoid status changed: ${Plasmoid.status}`)
        }
    }

    compactRepresentation: Item {
        id: compact

        Layout.preferredWidth: row.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.fillHeight: true

        readonly property real controlsSize: Math.min(height, Kirigami.Units.iconSizes.medium)

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

        RowLayout {
            id: row
            spacing: 0

            anchors.fill: parent

            PanelIcon {
                size: compact.controlsSize
                icon: plasmoid.configuration.panelIcon
                imageUrl: player.artUrl
                imageRadius: plasmoid.configuration.albumCoverRadius
                type: {
                    if (!plasmoid.configuration.useAlbumCoverAsPanelIcon) {
                        return PanelIcon.Type.Icon;
                    }
                    if (plasmoid.configuration.fallbackToIconWhenArtNotAvailable && !player.artUrl) {
                        return PanelIcon.Type.Icon;
                    }
                    return PanelIcon.Type.Image;
                }
                Layout.rightMargin: Kirigami.Units.smallSpacing * 2
            }


            Item {
                visible: plasmoid.configuration.separateText
                Layout.preferredHeight: column.implicitHeight
                Layout.preferredWidth: column.implicitWidth

                ColumnLayout {
                    id: column
                    spacing: 0
                    anchors.fill: parent
                    ScrollingText {
                        overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                        font: widget.boldTextFont
                        speed: plasmoid.configuration.textScrollingSpeed
                        maxWidth: plasmoid.configuration.maxSongWidthInPanel
                        text: player.title
                        scrollingEnabled: textScrollingEnabled
                        scrollResetOnPause: textScrollingResetOnPause
                    }
                    ScrollingText {
                        overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                        font: widget.textFont
                        speed: plasmoid.configuration.textScrollingSpeed
                        maxWidth: plasmoid.configuration.maxSongWidthInPanel
                        text: player.artists
                        scrollingEnabled: textScrollingEnabled
                        scrollResetOnPause: textScrollingResetOnPause
                    }
                }
            }

            ScrollingText {
                visible: !plasmoid.configuration.separateText
                overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                speed: plasmoid.configuration.textScrollingSpeed
                maxWidth: plasmoid.configuration.maxSongWidthInPanel
                text: [player.artists, player.title].filter((x) => x).join(" - ")
                font: widget.textFont
                scrollingEnabled: textScrollingEnabled
                scrollResetOnPause: textScrollingResetOnPause
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.canGoPrevious
                icon.name: "media-skip-backward"
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                MouseArea {
                    anchors.fill: parent
                    onClicked: player.previous()
                }
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                MouseArea {
                    anchors.fill: parent
                    onClicked: player.playPause()
                }
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.canGoNext
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: "media-skip-forward"
                MouseArea {
                    anchors.fill: parent
                    onClicked: player.next()
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
                    visible: player.artUrl
                    source: player.artUrl
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
