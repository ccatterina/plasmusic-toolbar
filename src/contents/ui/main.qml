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

        RowLayout {
            id: row
            spacing: 0

            anchors.fill: parent

            PanelIcon {
                size: compact.controlsSize
                icon: plasmoid.configuration.panelIcon
                imageUrl: player.artUrl
                type: plasmoid.configuration.useAlbumCoverAsPanelIcon ? "image": "icon"
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
                        font.bold: true
                        speed: plasmoid.configuration.textScrollingSpeed
                        maxWidth: plasmoid.configuration.maxSongWidthInPanel
                        text: player.title
                    }
                    ScrollingText {
                        overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                        speed: plasmoid.configuration.textScrollingSpeed
                        maxWidth: plasmoid.configuration.maxSongWidthInPanel
                        text: player.artists
                    }
                }
            }

            ScrollingText {
                visible: !plasmoid.configuration.separateText
                overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                speed: plasmoid.configuration.textScrollingSpeed
                maxWidth: plasmoid.configuration.maxSongWidthInPanel
                text: [player.artists, player.title].filter((x) => x).join(" - ")
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.canGoPrevious
                icon.name: "media-seek-backward"
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                onClicked: player.previous()
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                onClicked: player.playPause()
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.canGoNext
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: "media-seek-forward"
                onClicked: player.next()
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredHeight: column.implicitHeight
        Layout.preferredWidth: column.implicitWidth

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
                font.bold: true
                maxWidth: 250
                text: player.title
            }

            ScrollingText {
                speed: plasmoid.configuration.textScrollingSpeed
                maxWidth: 250
                text: player.artists
            }

            VolumeBar {
                Layout.leftMargin: 40
                Layout.rightMargin: 40
                Layout.topMargin: 10
                volume: player.volume
                onChangeVolume: (vol) => {
                    player.setVolume(vol)
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
                        source: "media-seek-backward"
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
                        source: "media-seek-forward"
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
