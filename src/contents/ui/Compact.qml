import "./components"
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris


Item {
    id: compact

    readonly property bool horizontal: widget.formFactor === PlasmaCore.Types.Horizontal
    readonly property bool fillAvailableSpace: plasmoid.configuration.fillAvailableSpace

    Layout.preferredWidth: grid.implicitWidth
    Layout.preferredHeight: grid.implicitHeight
    Layout.fillHeight: horizontal || fillAvailableSpace
    Layout.fillWidth: !horizontal || fillAvailableSpace

    readonly property int widgetThickness: Math.min(height, width)
    readonly property int controlsSize: Math.round(widgetThickness * 0.75)
    readonly property int lengthMargin: Math.round((widgetThickness - controlsSize)) / 2

    readonly property bool colorsFromAlbumCover: plasmoid.configuration.colorsFromAlbumCover
    readonly property bool useImageColors: panelIcon.imageReady && panelIcon.type == PanelIcon.Type.Image && colorsFromAlbumCover
    readonly property color imageColor: useImageColors ? panelIcon.imageColor : Kirigami.Theme.textColor
    readonly property color backgroundColorFromImage: Kirigami.ColorUtils.tintWithAlpha(imageColor, "black", 0.5)
    property color backgroundColor: useImageColors ? backgroundColorFromImage : "transparent"
    readonly property var backgroundColorBrightness: Kirigami.ColorUtils.brightnessForColor(backgroundColor)
    readonly property color contrastColor: backgroundColorBrightness === Kirigami.ColorUtils.Dark ? "white" : "black"
    readonly property color foregroundColorFromImage: Kirigami.ColorUtils.tintWithAlpha(imageColor, contrastColor, .6)
    property color foregroundColor: useImageColors ? foregroundColorFromImage : Kirigami.Theme.textColor

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

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        radius: plasmoid.configuration.panelBackgroundRadius
    }

    MouseAreaWithWheelHandler {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton
        propagateComposedEvents: true

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
                    widget.expanded = !widget.expanded;
                }
            }
        }

        onWheelUp: {
            player.changeVolume(plasmoid.configuration.volumeStep / 100, true);
        }

        onWheelDown: {
            player.changeVolume(-plasmoid.configuration.volumeStep / 100, true);
        }
    }

    GridLayout {
        id: grid

        columns: horizontal ? grid.children.length : 1
        rows: horizontal ? 1 : grid.children.length
        columnSpacing: Kirigami.Units.smallSpacing
        rowSpacing: Kirigami.Units.smallSpacing

        anchors.fill: parent

        PanelIcon {
            id: panelIcon

            Layout.leftMargin: horizontal ? lengthMargin: 0
            Layout.topMargin: horizontal ? 0 : lengthMargin
            Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

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
        }

        GridLayout {
            id: middleSpace

            columns: horizontal ? middleSpace.children.length : 1
            rows: horizontal ? 1 : middleSpace.children.length

            readonly property int textAlignment: plasmoid.configuration.songTextAlignment
            readonly property int length: horizontal ? width : height

            Layout.fillHeight: horizontal || fillAvailableSpace
            Layout.fillWidth: !horizontal || fillAvailableSpace
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.rightMargin: horizontal ? Kirigami.Units.smallSpacing : 0
            Layout.leftMargin: horizontal ? Kirigami.Units.smallSpacing : 0
            Layout.topMargin: horizontal ? 0 : Kirigami.Units.smallSpacing
            Layout.bottomMargin: horizontal ? 0: Kirigami.Units.smallSpacings

            Item {
                readonly property bool fill: middleSpace.textAlignment == Qt.AlignRight || middleSpace.textAlignment == Qt.AlignCenter
                Layout.fillHeight: !horizontal && fill
                Layout.fillWidth: horizontal && fill
            }

            Item {
                Layout.fillHeight: horizontal
                Layout.fillWidth: !horizontal
                Layout.preferredHeight: !horizontal ? songAndArtistText.width : null
                Layout.preferredWidth: horizontal ? songAndArtistText.width : null

                SongAndArtistText {
                    id: songAndArtistText
                    anchors.centerIn: parent

                    rotation: {
                        if (horizontal) return 0
                        if (widget.location === PlasmaCore.Types.LeftEdge) return -90
                        if (widget.location === PlasmaCore.Types.RightEdge) return 90
                    }

                    maxWidth: fillAvailableSpace ? middleSpace.length : plasmoid.configuration.maxSongWidthInPanel
                    splitSongAndArtists: plasmoid.configuration.separateText
                    scrollingBehaviour: plasmoid.configuration.textScrollingBehaviour
                    scrollingSpeed: plasmoid.configuration.textScrollingSpeed
                    scrollingResetOnPause: plasmoid.configuration.textScrollingResetOnPause
                    scrollingEnabled: plasmoid.configuration.textScrollingEnabled
                    textFont: baseFont
                    color: foregroundColor
                    title: player.title
                    artists: player.artists
                }
            }

            Item {
                readonly property bool fill: middleSpace.textAlignment == Qt.AlignLeft || middleSpace.textAlignment == Qt.AlignCenter
                Layout.fillHeight: !horizontal && fill
                Layout.fillWidth: horizontal && fill
            }
        }

        GridLayout {
            visible: plasmoid.configuration.commandsInPanel

            columns: horizontal ? grid.children.length : 1
            rows: horizontal ? 1 : grid.children.length

            Layout.rightMargin: horizontal ? lengthMargin : 0
            Layout.bottomMargin: horizontal ? 0: lengthMargin
            Layout.fillHeight: horizontal
            Layout.fillWidth: !horizontal
            Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

            PlasmaComponents3.ToolButton {
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

                enabled: player.canGoPrevious
                icon.name: "media-skip-backward"
                icon.color: foregroundColor
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                onClicked: player.previous()
            }

            PlasmaComponents3.ToolButton {
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

                enabled: player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                icon.color: foregroundColor
                onClicked: player.playPause()
            }

            PlasmaComponents3.ToolButton {
                Layout.alignment : Qt.AlignVCenter | Qt.AlignHCenter

                enabled: player.canGoNext
                implicitWidth: compact.controlsSize
                implicitHeight: compact.controlsSize
                icon.name: "media-skip-forward"
                icon.color: foregroundColor
                onClicked: player.next()
            }
        }
    }
}