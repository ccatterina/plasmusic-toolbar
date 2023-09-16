import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

Item {
    id: widget

    PlayerDataSource {
        id: player
        sourceName: plasmoid.configuration.sourceName
    }

    visible: player.ready

    Plasmoid.compactRepresentation: Item {
        Layout.preferredWidth: player.ready ? row.implicitWidth + 20 * units.devicePixelRatio : 0

        MouseArea {
            visible: player.ready
            anchors.fill: parent
            onClicked: () => { plasmoid.expanded = !plasmoid.expanded; }
        }

        RowLayout {
            id: row

            anchors.fill: parent
            visible: player.ready

            PlasmaCore.IconItem {
                source: plasmoid.configuration.panelIcon
                width: PlasmaCore.Units.iconSizes.small
                height: width
            }

            SlidingText {
                maxWidth: plasmoid.configuration.maxSongWidthInPanel * units.devicePixelRatio
                text: `${player.artists.join(", ")} - ${player.title}`
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                icon.name: "media-seek-backward"
                onClicked: player.startOperation("Previous")
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                icon.name: player.playbackStatus === "Playing" ? "media-playback-pause" : "media-playback-start"
                onClicked: player.startOperation("PlayPause")
            }

            PlasmaComponents3.ToolButton {
                visible: plasmoid.configuration.commandsInPanel
                icon.name: "media-seek-forward"
                onClicked: player.startOperation("Next")
            }
        }

    }

    Plasmoid.fullRepresentation: Item {
        Layout.preferredHeight: column.implicitHeight
        Layout.preferredWidth: column.implicitWidth
        visible: player.ready

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
                }
            }

            TrackPositionSlider {
                Layout.leftMargin: 20 * units.devicePixelRatio
                Layout.rightMargin: 20 * units.devicePixelRatio
                songPosition: player.songPosition
                lastSongPositionUpdate: player.lastSongPositionUpdate
                songLength: player.songLength
                playing: player.playbackStatus === 'Playing'
                onChangePosition: (delta) => {
                    player.startOperation("Seek", {microseconds: delta})
                }
            }

            SlidingText {
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                maxWidth: 250 * units.devicePixelRatio
                text: player.title
            }

            SlidingText {
                Layout.alignment: Qt.AlignHCenter
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
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: "media-playlist-shuffle"
                        onClicked: player.startOperation("SetShuffle", { on: !player.shuffle })
                        active: player.shuffle
                    }

                    CommandIcon {
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: "media-seek-backward"
                        onClicked: player.startOperation("Previous")
                    }

                    CommandIcon {
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.large
                        source: player.playbackStatus === "Playing" ? "media-playback-pause" : "media-playback-start"
                        onClicked: player.startOperation("PlayPause")
                    }

                    CommandIcon {
                        Layout.alignment: Qt.AlignHCenter
                        size: PlasmaCore.Units.iconSizes.medium
                        source: "media-seek-forward"
                        onClicked: player.startOperation("Next")
                    }

                    CommandIcon {
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
