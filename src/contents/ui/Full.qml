import "./components"
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris


Item {
    property string albumPlaceholder: plasmoid.configuration.albumPlaceholder
    property real volumeStep: plasmoid.configuration.volumeStep

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
                source: player.artUrl || albumPlaceholder
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

        SongAndArtistText {
            Layout.alignment: Qt.AlignHCenter
            scrollingSpeed: plasmoid.configuration.fullViewTextScrollingSpeed
            splitSongAndArtists: true
            title: player.title
            artists: player.artists
            textFont: baseFont
            maxWidth: 250
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