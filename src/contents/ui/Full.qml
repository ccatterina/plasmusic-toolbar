import "./components"
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris
import Qt5Compat.GraphicalEffects


Item {
    property string albumPlaceholder: plasmoid.configuration.albumPlaceholder
    property real volumeStep: plasmoid.configuration.volumeStep
    property bool useImageColors: plasmoid.configuration.fullAlbumCoverAsBackground
    // property int fullViewImplicitMargins: 5

    Layout.preferredHeight: column.implicitHeight
    Layout.preferredWidth: column.implicitWidth
    Layout.minimumWidth: column.implicitWidth
    Layout.minimumHeight: column.implicitHeight
    // Layout.maximumWidth: column.implicitWidth
    // Layout.maximumHeight: column.implicitHeight

    Kirigami.Theme.backgroundColor: useImageColors ? imageColors.bgColor : Kirigami.Theme.backgroundColor
    Kirigami.Theme.textColor: useImageColors ? imageColors.fgColor : Kirigami.Theme.textColor
    Kirigami.Theme.highlightColor: useImageColors ? imageColors.fgHighlightColor : Kirigami.Theme.highlightColor

    Image {
        visible: useImageColors
        id: albumArtFull
        Layout.margins: 0
        Layout.alignment: Qt.AlignHCenter
        anchors.horizontalCenter: column.horizontalCenter
        anchors.verticalCenter: Layout.verticalCenter
        height: column.height // + fullViewImplicitMargins * 2
        width: column.width // + fullViewImplicitMargins * 2
        // x: -fullViewImplicitMargins
        // y: -fullViewImplicitMargins
        // z: -1
        fillMode: Image.PreserveAspectCrop
        
        onStatusChanged: {
            if (status === Image.Ready) {
                imageColors.update()
            }
        }

        source: {
            if (status === Image.Error || !player.artUrl) {
                return albumPlaceholder;
            }
            return player.artUrl;
        }

        Kirigami.ImageColors {
            id: imageColors
            source: albumArtFull

            readonly property color bgColor: Kirigami.ColorUtils.tintWithAlpha(dominant, "black", 0.4)
            readonly property var bgColorBrightness: Kirigami.ColorUtils.brightnessForColor(bgColor)
            readonly property color contrastColor: bgColorBrightness === Kirigami.ColorUtils.Dark ? "white" : "black"
            readonly property color fgColor: Kirigami.ColorUtils.tintWithAlpha(dominant, contrastColor, .6)
            readonly property color fgHighlightColor: Kirigami.ColorUtils.tintWithAlpha(dominant, contrastColor, 0.8)
        }
    }

    LinearGradient {
        id: mask
        anchors.fill: albumArtFull
        visible: useImageColors
        gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.4; color: "transparent" }
            GradientStop { position: 0.7; color: imageColors.bgColor }
            GradientStop { position: 1; color: imageColors.bgColor }
        }
    }

    ColumnLayout {
        id: column

        spacing: 0
        anchors.fill: parent

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: useImageColors ? 0 : 10
            width: 300
            height: width
            color: 'transparent'

            PlasmaComponents3.ToolTip {
                id: raisePlayerTooltip
                anchors.centerIn: parent
                text: player.canRaise ? i18n("Bring player to the front") : i18n("This player can't be raised")
                visible: coverMouseArea.containsMouse
            }

            MouseArea {
                id: coverMouseArea
                anchors.fill: parent
                cursorShape: player.canRaise ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (player.canRaise) player.raise()
                }
                hoverEnabled: true
            }


            Image {
                visible: !plasmoid.configuration.fullAlbumCoverAsBackground
                id: albumArtNormal
                anchors.fill: parent
                source: {
                    if (status === Image.Error || !player.artUrl) {
                        return albumPlaceholder;
                    }
                    return player.artUrl;
                }

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

        SongAndArtistText {
            Layout.alignment: Qt.AlignHCenter
            scrollingSpeed: plasmoid.configuration.fullViewTextScrollingSpeed
            title: player.title
            artists: player.artists
            album: player.album
            textFont: baseFont
            maxWidth: 250
            titlePosition: plasmoid.configuration.fullTitlePosition
            artistsPosition: plasmoid.configuration.fullArtistsPosition
            albumPosition: plasmoid.configuration.fullAlbumPosition
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