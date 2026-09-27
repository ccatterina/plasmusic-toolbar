import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

// Compact representation used when the widget lives in the system tray.
// By default it is a plain icon that opens the full view. With the
// "Show only the playback controls" option, the tray popup shows
// previous / play-pause / next buttons instead.
Item {
    id: root

    // The tray item that hosts this widget (it exposes `inHiddenLayout`).
    property Item trayItem: findTrayItem()
    readonly property bool inHiddenLayout: trayItem ? trayItem.inHiddenLayout : false
    readonly property bool showControls: widget.trayPlaybackControlsOnly && inHiddenLayout

    onParentChanged: trayItem = findTrayItem()

    function findTrayItem() {
        let p = root.parent
        while (p && p.inHiddenLayout === undefined) {
            p = p.parent
        }
        return p
    }

    // In the popup grid the tray places its own MouseArea above every item and only
    // forwards clicks to a MouseArea that covers the whole compact representation,
    // with coordinates relative to the tray item. So a single area receives the click
    // and works out which button is under the pointer.
    function handleClick(mouse) {
        if (!showControls) {
            widget.expanded = !widget.expanded
            return
        }
        const pt = trayItem ? trayItem.mapToItem(controls, mouse.x, mouse.y) : root.mapToItem(controls, mouse.x, mouse.y)
        const button = controls.childAt(pt.x, controls.height / 2)
        if (!button || !button.action) {
            widget.expanded = !widget.expanded
            return
        }
        if (!button.enabled) {
            return
        }
        if (button.action === "previous") {
            player.previous()
        } else if (button.action === "next") {
            player.next()
        } else {
            player.playPause()
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPressed: mouse => {}
        onClicked: mouse => root.handleClick(mouse)
    }

    Kirigami.Icon {
        visible: !root.showControls
        anchors.fill: parent
        source: Plasmoid.icon
    }

    Row {
        id: controls
        visible: root.showControls
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Kirigami.Units.smallSpacing * 2

        Repeater {
            model: ["previous", "playPause", "next"]
            delegate: Kirigami.Icon {
                required property string modelData
                readonly property string action: modelData

                width: root.height
                height: width
                source: {
                    if (action === "previous") return "media-skip-backward"
                    if (action === "next") return "media-skip-forward"
                    return player.playbackStatus === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                }
                enabled: {
                    if (action === "previous") return player.canGoPrevious
                    if (action === "next") return player.canGoNext
                    return player.playbackStatus === Mpris.PlaybackStatus.Playing ? player.canPause : player.canPlay
                }
                opacity: enabled ? 1 : 0.4
            }
        }
    }
}
