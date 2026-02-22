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
    id: root

    property string albumPlaceholder: plasmoid.configuration.albumPlaceholder
    property real volumeStep: plasmoid.configuration.volumeStep
    property bool albumCoverBackground: plasmoid.configuration.fullAlbumCoverAsBackground
    property bool thumbnailVisible: plasmoid.configuration.fullViewThumbnailVisible
    property bool progressBarVisible: plasmoid.configuration.fullViewProgressBarVisible
    property bool volumeControlVisible: plasmoid.configuration.fullViewVolumeControlVisible
    property bool shuffleVisible: plasmoid.configuration.fullViewShuffleVisible
    property bool playbackControlsVisible: plasmoid.configuration.fullViewPlaybackControlsVisible
    property bool loopVisible: plasmoid.configuration.fullViewLoopVisible
    property bool playbackControlsFitWidth: plasmoid.configuration.fullViewPlaybackControlsFillWidth
    property bool songTextVisible: plasmoid.configuration.fullViewSongTextVisible
    property int songTextAlignment: plasmoid.configuration.fullViewSongTextAlignment
    property bool songTextAboveProgressBar: plasmoid.configuration.fullViewSongTextPosition === SongAndArtistText.VerticalPosition.AboveProgressBar

    // The Full View max and min width is driven by config values. The window can be resized within these bounds; thumbnail and text adapt.
    readonly property int configMinWidth: plasmoid.configuration.fullViewMinWidth
    readonly property int maximumWidth: plasmoid.configuration.fullViewMaxWidth

    // Override min width if visible content (e.g. playback controls) needs more space
    readonly property int contentMinWidth: row.visible ? row.implicitWidth + 40 : 0
    readonly property int effectiveMinWidth: Math.min(Math.max(configMinWidth, contentMinWidth), maximumWidth)

    Layout.preferredWidth: maximumWidth
    Layout.minimumWidth: effectiveMinWidth
    Layout.maximumWidth: maximumWidth
    Layout.preferredHeight: column.implicitHeight
    Layout.minimumHeight: column.implicitHeight
    Layout.maximumHeight: column.implicitHeight

    // Store the original theme colors (root keeps default Kirigami.Theme.inherit: true)
    readonly property color _originalTextColor: Kirigami.Theme.textColor
    readonly property color _originalHighlightColor: Kirigami.Theme.highlightColor

    Item {
        visible: albumCoverBackground && thumbnailVisible
        Layout.margins: 0
        anchors.centerIn: parent
        height: column.height
        width: column.width

        ImageWithPlaceholder {
            id: albumArtFull
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height * 0.7
            width: parent.width
            fillMode: Image.PreserveAspectCrop
            placeholderSource: albumPlaceholder
            imageSource: player.artUrl

            onStatusChanged: {
                if (status === Image.Ready) {
                    imageColors.update()
                }
            }

            Kirigami.ImageColors {
                id: imageColors
                source: albumArtFull
                readonly property color bgColor: average
                readonly property var bgColorBrightness: Kirigami.ColorUtils.brightnessForColor(bgColor)
                readonly property color contrastColor: bgColorBrightness === Kirigami.ColorUtils.Dark ? "white" : "black"
                readonly property color fgColor: Kirigami.ColorUtils.tintWithAlpha(bgColor, contrastColor, .6)
                readonly property color hlColor: Kirigami.ColorUtils.tintWithAlpha(bgColor, contrastColor, .8)
            }
        }

        LinearGradient {
            id: mask
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.4; color: "transparent" }
                GradientStop { position: 0.7; color: imageColors.bgColor }
                GradientStop { position: 1; color: imageColors.bgColor }
            }
        }
    }


    ColumnLayout {
        id: column

        spacing: 0
        anchors.fill: parent

        // Override theme ONLY for this layout and its children
        Kirigami.Theme.inherit: false
        Kirigami.Theme.textColor: albumCoverBackground ? imageColors.fgColor : root._originalTextColor
        Kirigami.Theme.highlightColor: albumCoverBackground ? imageColors.hlColor : root._originalHighlightColor

        Rectangle {
            id: thumbnailContainer
            visible: thumbnailVisible
            Layout.fillWidth: true
            Layout.margins: 10
            // Use the actual image aspect ratio, fallback to square if not loaded yet
            readonly property real imageRatio: albumArtNormal.implicitWidth > 0 && albumArtNormal.implicitHeight > 0
                ? albumArtNormal.implicitWidth / albumArtNormal.implicitHeight
                : 1.0
            Layout.preferredHeight: thumbnailVisible ? width / imageRatio : 0
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

            ImageWithPlaceholder {
                visible: !albumCoverBackground
                id: albumArtNormal
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

                placeholderSource: albumPlaceholder
                imageSource: player.artUrl
            }
        }

        SongAndArtistText {
            visible: songTextVisible && songTextAboveProgressBar
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 5
            textAlignment: songTextAlignment
            scrollingSpeed: plasmoid.configuration.fullViewTextScrollingSpeed
            title: player.title
            artists: player.artists
            album: player.album
            textFont: baseFont
            maxWidth: width
            titlePosition: plasmoid.configuration.fullTitlePosition
            artistsPosition: plasmoid.configuration.fullArtistsPosition
            albumPosition: plasmoid.configuration.fullAlbumPosition
        }

        TrackPositionSlider {
            visible: progressBarVisible
            Layout.leftMargin: 10
            Layout.rightMargin: 10
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
            id: songText
            visible: songTextVisible && !songTextAboveProgressBar
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 5
            textAlignment: songTextAlignment
            scrollingSpeed: plasmoid.configuration.fullViewTextScrollingSpeed
            title: player.title
            artists: player.artists
            album: player.album
            textFont: baseFont
            maxWidth: songText.width
            titlePosition: plasmoid.configuration.fullTitlePosition
            artistsPosition: plasmoid.configuration.fullArtistsPosition
            albumPosition: plasmoid.configuration.fullAlbumPosition
        }

        VolumeBar {
            visible: volumeControlVisible
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
            visible: shuffleVisible || playbackControlsVisible || loopVisible
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: 10
            Layout.fillWidth: playbackControlsFitWidth
            Layout.alignment: playbackControlsFitWidth ? 0 : Qt.AlignHCenter
            Layout.preferredWidth: playbackControlsFitWidth ? -1 : row.implicitWidth
            Layout.preferredHeight: row.implicitHeight
            RowLayout {
                id: row

                width: playbackControlsFitWidth ? parent.width : implicitWidth
                height: implicitHeight
                anchors.centerIn: parent

                CommandIcon {
                    visible: shuffleVisible
                    enabled: player.canChangeShuffle
                    Layout.alignment: Qt.AlignHCenter
                    size: Kirigami.Units.iconSizes.medium
                    source: "media-playlist-shuffle"
                    onClicked: player.setShuffle(player.shuffle === Mpris.ShuffleStatus.Off ? Mpris.ShuffleStatus.On : Mpris.ShuffleStatus.Off)
                    active: player.shuffle === Mpris.ShuffleStatus.On
                }

                CommandIcon {
                    visible: playbackControlsVisible
                    enabled: player.canGoPrevious
                    Layout.alignment: Qt.AlignHCenter
                    size: Kirigami.Units.iconSizes.medium
                    source: "media-skip-backward"
                    onClicked: player.previous()
                }

                CommandIcon {
                    visible: playbackControlsVisible
                    enabled: player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                    Layout.alignment: Qt.AlignHCenter
                    size: Kirigami.Units.iconSizes.large
                    source: player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                    onClicked: player.playPause()
                }

                CommandIcon {
                    visible: playbackControlsVisible
                    enabled: player.canGoNext
                    Layout.alignment: Qt.AlignHCenter
                    size: Kirigami.Units.iconSizes.medium
                    source: "media-skip-forward"
                    onClicked: player.next()
                }

                CommandIcon {
                    visible: loopVisible
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
