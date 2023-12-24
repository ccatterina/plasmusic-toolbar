import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

Item {
    id: widget

    Plasmoid.status: PlasmaCore.Types.HiddenStatus
    PlayerDataSource {
        id: player
        sourceName: plasmoid.configuration.sources[plasmoid.configuration.sourceIndex]
        onReadyChanged: () => {
            plasmoid.status = ready ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
        }
    }

    Plasmoid.compactRepresentation: Item {
        id: compactRepresentation

        Layout.preferredWidth: row.implicitWidth + PlasmaCore.Units.smallSpacing * 2
        Layout.fillHeight: true

        readonly property real controlsSize: Math.min(height, PlasmaCore.Units.iconSizes.medium)

        MouseArea {
            anchors.fill: parent
            onClicked: () => { plasmoid.expanded = !plasmoid.expanded; }
        }

        RowLayout {
            id: row
            spacing: 0

            anchors.fill: parent

            PanelIcon {
                size: compactRepresentation.controlsSize
                icon: plasmoid.configuration.panelIcon
                imageUrl: player.artUrl
                type: plasmoid.configuration.useAlbumCoverAsPanelIcon ? "image": "icon"
                Layout.rightMargin: PlasmaCore.Units.smallSpacing * 2
            }

            ScrollingText {
                overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
                speed: plasmoid.configuration.textScrollingSpeed
                maxWidth: plasmoid.configuration.maxSongWidthInPanel * units.devicePixelRatio
                text: [player.artists.join(", "), player.title].filter((x) => x).join(" - ")
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.canGoPrevious
                icon.name: "media-seek-backward"
                implicitWidth: compactRepresentation.controlsSize
                implicitHeight: compactRepresentation.controlsSize
                onClicked: player.startOperation("Previous")
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.playbackStatus === "Playing" ? player.canPause : player.canPlay
                implicitWidth: compactRepresentation.controlsSize
                implicitHeight: compactRepresentation.controlsSize
                icon.name: player.playbackStatus === "Playing" ? "media-playback-pause" : "media-playback-start"
                onClicked: player.startOperation("PlayPause")
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                enabled: player.canGoNext
                implicitWidth: compactRepresentation.controlsSize
                implicitHeight: compactRepresentation.controlsSize
                icon.name: "media-seek-forward"
                onClicked: player.startOperation("Next")
            }
        }

    }

    Plasmoid.fullRepresentation: Item {
        Layout.preferredHeight: column.implicitHeight
        Layout.preferredWidth: column.implicitWidth

        ColumnLayout {
            id: column

            spacing: 0
            anchors.fill: parent

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10 * units.devicePixelRatio
                width: 300 * units.devicePixelRatio
                height: width

                Image {
                    anchors.fill: parent
                    visible: player.artUrl
                    source: player.artUrl
                    fillMode: Image.PreserveAspectFit
                }
            }

            TrackPositionSlider {
                Layout.leftMargin: 20 * units.devicePixelRatio
                Layout.rightMargin: 20 * units.devicePixelRatio
                songPosition: player.songPosition
                lastSongPositionUpdate: player.lastSongPositionUpdate
                songLength: player.songLength
                playing: player.playbackStatus === 'Playing'
                enableChangePosition: player.canSeek
                onChangePosition: (delta) => {
                    player.startOperation("Seek", {microseconds: delta})
                }
            }

            ScrollingText {
                speed: plasmoid.configuration.textScrollingSpeed
                font.bold: true
                maxWidth: 250 * units.devicePixelRatio
                text: player.title
            }

            ScrollingText {
                speed: plasmoid.configuration.textScrollingSpeed
                maxWidth: 250 * units.devicePixelRatio
                text: player.artists.join(", ")
            }

            VolumeBar {
                Layout.leftMargin: 40 * units.devicePixelRatio
                Layout.rightMargin: 40 * units.devicePixelRatio
                Layout.topMargin: 10 * units.devicePixelRatio
                volume: player.volume
                onChangeVolume: (vol) => {
                    player.startOperation("SetVolume", {level: vol})
                }
            }

            Item {
                Layout.leftMargin: 20 * units.devicePixelRatio
                Layout.rightMargin: 20 * units.devicePixelRatio
                Layout.bottomMargin: 10 * units.devicePixelRatio
                Layout.fillWidth: true
                Layout.preferredHeight: row.implicitHeight
                RowLayout {
                    id: row

                    anchors.fill: parent

                    CommandIcon {
                        enabled: player.canChangeShuffle
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: "media-playlist-shuffle"
                        onClicked: player.startOperation("SetShuffle", { on: !player.shuffle })
                        active: player.shuffle
                    }

                    CommandIcon {
                        enabled: player.canGoPrevious
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: "media-seek-backward"
                        onClicked: player.startOperation("Previous")
                    }

                    CommandIcon {
                        enabled: player.playbackStatus === "Playing" ? player.canPause : player.canPlay
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.large
                        source: player.playbackStatus === "Playing" ? "media-playback-pause" : "media-playback-start"
                        onClicked: player.startOperation("PlayPause")
                    }

                    CommandIcon {
                        enabled: player.canGoNext
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: "media-seek-forward"
                        onClicked: player.startOperation("Next")
                    }

                    CommandIcon {
                        enabled: player.canChangeLoopStatus
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: player.loopStatus === "Track" ? "media-playlist-repeat-song" : "media-playlist-repeat"
                        active: player.loopStatus != "None"
                        onClicked: () => {
                            let status = "None";
                            if (player.loopStatus == "None")
                                status = "Track";
                            else if (player.loopStatus === "Track")
                                status = "Playlist";
                            player.startOperation("SetLoopStatus", { status });
                        }
                    }

                }

            }

        }

    }
}
