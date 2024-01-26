import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.4 as Kirigami


Item {
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
            playing: player.playbackStatus === Player.PlaybackStatus.Playing
            enableChangePosition: player.canSeek
            onRequireChangePosition: (delta) => {
                player.seek(delta)
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
            text: player.artists.join(", ")
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
                    onClicked: player.setShuffle(player.shuffle === Player.ShuffleStatus.Off ? Player.ShuffleStatus.On : Player.ShuffleStatus.Off)
                    active: player.shuffle === Player.ShuffleStatus.On
                }

                CommandIcon {
                    enabled: player.canGoPrevious
                    Layout.alignment: Qt.AlignHCenter
                    size: Kirigami.Units.iconSizes.medium
                    source: "media-seek-backward"
                    onClicked: player.previous()
                }

                CommandIcon {
                    enabled: player.playbackStatus === Player.PlaybackStatus.Playing ? player.canPause : player.canPlay
                    Layout.alignment: Qt.AlignHCenter
                    size: Kirigami.Units.iconSizes.large
                    source: player.playbackStatus === Player.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
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
                    source: player.loopStatus === Player.LoopStatus.Track ? "media-playlist-repeat-song" : "media-playlist-repeat"
                    active: player.loopStatus != Player.LoopStatus.None
                    onClicked: () => {
                        let status = Player.LoopStatus.None;
                        if (player.loopStatus == Player.LoopStatus.None)
                            status = Player.LoopStatus.Track;
                        else if (player.loopStatus === Player.LoopStatus.Track)
                            status = Player.LoopStatus.Playlist;
                        player.setLoopStatus(status);
                    }
                }

            }

        }

    }
}