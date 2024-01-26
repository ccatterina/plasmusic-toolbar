import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: compactRepresentation

    Layout.preferredWidth: row.implicitWidth + Kirigami.Units.smallSpacing * 2
    Layout.fillHeight: true

    readonly property real controlsSize: Math.min(height, Kirigami.Units.iconSizes.medium)

    MouseArea {
        anchors.fill: parent
        onClicked: () => {
            try {
                widget.expanded = !widget.expanded;
            } catch (e) {
                plasmoid.expanded = !plasmoid.expanded;
            }
        }
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
                    text: player.artists.join(", ")
                }
            }
        }

        ScrollingText {
            visible: !plasmoid.configuration.separateText
            overflowBehaviour: plasmoid.configuration.textScrollingBehaviour
            speed: plasmoid.configuration.textScrollingSpeed
            maxWidth: plasmoid.configuration.maxSongWidthInPanel
            text: [player.artists.join(", "), player.title].filter((x) => x).join(" - ")
        }

        PlasmaComponents3.ToolButton {
            visible: plasmoid.configuration.commandsInPanel
            enabled: player.canGoPrevious
            icon.name: "media-seek-backward"
            implicitWidth: compactRepresentation.controlsSize
            implicitHeight: compactRepresentation.controlsSize
            onClicked: player.previous()
        }

        PlasmaComponents3.ToolButton {
            visible: plasmoid.configuration.commandsInPanel
            enabled: player.playbackStatus === Player.PlaybackStatus.Playing ? player.canPause : player.canPlay
            implicitWidth: compactRepresentation.controlsSize
            implicitHeight: compactRepresentation.controlsSize
            icon.name: player.playbackStatus === Player.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
            onClicked: player.playPause()
        }

        PlasmaComponents3.ToolButton {
            visible: plasmoid.configuration.commandsInPanel
            enabled: player.canGoNext
            implicitWidth: compactRepresentation.controlsSize
            implicitHeight: compactRepresentation.controlsSize
            icon.name: "media-seek-forward"
            onClicked: player.next()
        }
    }
}
