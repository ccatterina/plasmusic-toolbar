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

    enum SongAndArtistTextPosition {
        AboveProgressBar,
        UnderProgressBar
    }

    enum PlayerSelectorPosition {
        Top,
        Side
    }

    enum AlbumCoverHeight {
        FitImage,
        Fixed
    }

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
    property bool songTextAboveProgressBar: plasmoid.configuration.fullViewSongTextPosition === Full.SongAndArtistTextPosition.AboveProgressBar
    property bool playerSelectorEnabled: plasmoid.configuration.showPlayerSelector && player.sourceIdentities == null
    property bool playerSelectorOnSide: plasmoid.configuration.playerSelectorPosition === Full.PlayerSelectorPosition.Side
    property bool albumCoverFixedHeight: plasmoid.configuration.fullAlbumCoverHeight === Full.AlbumCoverHeight.Fixed

    // The Full View max and min width is driven by config values. The window can be resized within these bounds; thumbnail and text adapt.
    readonly property int configMinWidth: plasmoid.configuration.fullViewMinWidth
    readonly property int maximumWidth: plasmoid.configuration.fullViewMaxWidth
    property bool fullAlbumCoverRounded: plasmoid.configuration.fullAlbumCoverRounded
    property int albumCoverRadius: plasmoid.configuration.fullAlbumCoverRadius

    // Override min width if visible content (e.g. playback controls) needs more space
    readonly property int contentMinWidth: row.visible ? row.implicitWidth + 40 : 0
    readonly property int effectiveMinWidth: Math.min(Math.max(configMinWidth, contentMinWidth), maximumWidth)

    // Extra width taken by the side player list, added on top of the configured width bounds
    readonly property int sidePlayerListWidth: sidePlayerList.visible ? Kirigami.Units.gridUnit * 11 : 0

    Layout.minimumWidth: effectiveMinWidth + sidePlayerListWidth
    Layout.maximumWidth: maximumWidth + sidePlayerListWidth
    Layout.preferredWidth: effectiveMinWidth + sidePlayerListWidth
    Layout.preferredHeight: column.implicitHeight
    Layout.minimumHeight: column.implicitHeight
    Layout.maximumHeight: column.implicitHeight

    // Store the original theme colors (root keeps default Kirigami.Theme.inherit: true)
    readonly property color _originalTextColor: Kirigami.Theme.textColor
    readonly property color _originalHighlightColor: Kirigami.Theme.highlightColor

    Item {
        visible: albumCoverBackground && thumbnailVisible
        Layout.margins: 0
        x: column.x
        y: column.y
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

            layer.enabled: root.fullAlbumCoverRounded && root.albumCoverRadius > 0
			layer.effect: OpacityMask {
				maskSource: Item {
					width: albumArtFull.width
					height: albumArtFull.height
					Rectangle {
						anchors.fill: parent
						radius: albumCoverRadius
                        bottomRightRadius: 0
                        bottomLeftRadius: 0
					}
				}
			}
        }

        LinearGradient {
            id: mask
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: headerbar.visible ? imageColors.bgColor : "transparent" }   // Adjust top gradient when the player selector is visible
                GradientStop { position: 0.11; color: "transparent" }
                GradientStop { position: headerbar.visible ? 0.5 : 0.4; color: "transparent" }
                GradientStop { position: 0.7; color: imageColors.bgColor }
                GradientStop { position: 1; color: imageColors.bgColor }
            }
        }
    }


    ColumnLayout {
        id: column

        spacing: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.width - root.sidePlayerListWidth

        // Override theme ONLY for this layout and its children
        Kirigami.Theme.inherit: false
        Kirigami.Theme.textColor: albumCoverBackground ? imageColors.fgColor : root._originalTextColor
        Kirigami.Theme.highlightColor: albumCoverBackground ? imageColors.hlColor : root._originalHighlightColor

        // Media Player Selector
        Rectangle {
            id: headerbar
            Layout.fillWidth: true
            visible: root.playerSelectorEnabled
                    && !root.playerSelectorOnSide
                    && playerList.count > 2

            color: albumCoverBackground
                ? "transparent"
                : Kirigami.Theme.backgroundColor

            implicitHeight: Kirigami.Units.gridUnit * 2

            PlasmaComponents3.TabBar {
                id: playerSelector
                objectName: "playerSelector"
                anchors.fill: parent
                implicitHeight: contentHeight
                currentIndex: player.mpris2Model.currentIndex

                Repeater {
                    id: playerList
                    model: player.mpris2Model
                    delegate: PlasmaComponents3.TabButton {
                        required property string iconName
                        required property bool isMultiplexer
                        required property string identity
                        required property int index
                        anchors.top: parent?.top
                        anchors.bottom: parent?.bottom
                        display: PlasmaComponents3.AbstractButton.IconOnly
                        icon.name: iconName
                        icon.height: Kirigami.Units.iconSizes.small
                        text: isMultiplexer ? i18nc("@action:button", "Choose player automatically") : identity

                        Accessible.onPressAction: clicked()
                        onClicked: {
                            player.mpris2Model.currentIndex = index;
                        }

                        PlasmaComponents3.ToolTip.text: text
                        PlasmaComponents3.ToolTip.delay: Kirigami.Units.toolTipDelay
                        PlasmaComponents3.ToolTip.visible: hovered || (activeFocus && (focusReason === Qt.TabFocusReason || focusReason === Qt.BacktabFocusReason))
                    }
                }
            }
        }

        Rectangle {
            id: thumbnailContainer
            visible: thumbnailVisible
            Layout.fillWidth: true
            Layout.margins: 10
            // Use the actual image aspect ratio, fallback to square if not loaded yet
            readonly property real imageRatio: albumArtNormal.implicitWidth > 0 && albumArtNormal.implicitHeight > 0
                ? albumArtNormal.implicitWidth / albumArtNormal.implicitHeight
                : 1.0
            // In fixed mode the container keeps a 4:3 box and the image is fitted inside it,
            // so the popup doesn't change height when switching between covers of different shapes
            Layout.preferredHeight: thumbnailVisible ? (root.albumCoverFixedHeight ? width * 3 / 4 : width / imageRatio) : 0
            color: 'transparent'

            PlasmaComponents3.ToolTip {
                id: raisePlayerTooltip
                anchors.centerIn: parent
                text: player.canRaise ? i18n("Bring player to the front") : i18n("This player can't be raised")
                visible: !plasmoid.configuration.hideCanBeRaisedTooltip && coverMouseArea.containsMouse
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

                layer.enabled: root.fullAlbumCoverRounded && root.albumCoverRadius > 0
                layer.effect: OpacityMask {
					maskSource: Item {
						width: albumArtNormal.width
						height: albumArtNormal.height
						Rectangle {
							anchors.fill: parent
							radius: albumCoverRadius
						}
					}
				}
            }
        }

        SongAndArtistText {
            visible: songTextVisible && songTextAboveProgressBar
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 5
            textAlignment: songTextAlignment
            scrollingSpeed: plasmoid.configuration.fullViewTextScrollingSpeed
            title: player.title
            artists: player.artists
            album: player.album
            textFont: baseFont
            titlePosition: plasmoid.configuration.fullTitlePosition
            artistsPosition: plasmoid.configuration.fullArtistsPosition
            albumPosition: plasmoid.configuration.fullAlbumPosition
            hideAlbumForSingles: plasmoid.configuration.fullHideAlbumForSingles
            scrollingEnabled: widget.expanded
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
            visible: songTextVisible && !songTextAboveProgressBar
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 5
            textAlignment: songTextAlignment
            scrollingSpeed: plasmoid.configuration.fullViewTextScrollingSpeed
            title: player.title
            artists: player.artists
            album: player.album
            textFont: baseFont
            titlePosition: plasmoid.configuration.fullTitlePosition
            artistsPosition: plasmoid.configuration.fullArtistsPosition
            albumPosition: plasmoid.configuration.fullAlbumPosition
            hideAlbumForSingles: plasmoid.configuration.fullHideAlbumForSingles
            scrollingEnabled: widget.expanded

            // Copy Track Info
            TextCopyArea {
                anchors.fill: parent
                text: player.title + " | " + player.artists
                helpText: i18n("Click to copy the track info")
            }
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

    // Media Player Selector (side list)
    Item {
        id: sidePlayerList
        visible: root.playerSelectorEnabled
                && root.playerSelectorOnSide
                && sidePlayerListView.count > 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.sidePlayerListWidth

        Kirigami.Separator {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }

        ListView {
            id: sidePlayerListView
            objectName: "sidePlayerSelector"
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
            clip: true
            spacing: Kirigami.Units.smallSpacing / 2
            boundsBehavior: Flickable.StopAtBounds
            model: player.mpris2Model
            currentIndex: player.mpris2Model.currentIndex

            delegate: PlasmaComponents3.ItemDelegate {
                id: playerDelegate
                required property string iconName
                required property bool isMultiplexer
                required property string identity
                required property string track
                required property int playbackStatus
                required property int index

                width: ListView.view.width
                highlighted: ListView.isCurrentItem
                text: isMultiplexer ? i18nc("@action:button", "Choose player automatically") : identity

                Accessible.onPressAction: clicked()
                onClicked: {
                    player.mpris2Model.currentIndex = index;
                }

                PlasmaComponents3.ToolTip.text: isMultiplexer || !track ? text : text + "\n" + track
                PlasmaComponents3.ToolTip.delay: Kirigami.Units.toolTipDelay
                PlasmaComponents3.ToolTip.visible: hovered

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: isMultiplexer ? "media-playlist-shuffle" : iconName
                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: playerDelegate.text
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            visible: !isMultiplexer && track.length > 0
                            text: track
                            font: Kirigami.Theme.smallFont
                            opacity: 0.7
                            elide: Text.ElideRight
                        }
                    }

                    Kirigami.Icon {
                        visible: !isMultiplexer && playbackStatus === Mpris.PlaybackStatus.Playing
                        source: "media-playback-start"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
