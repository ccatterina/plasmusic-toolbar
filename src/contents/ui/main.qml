import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris


PlasmoidItem {
    id: widget

    Plasmoid.status: widget.updateStatus()
    Plasmoid.backgroundHints: plasmoid.configuration.desktopWidgetBg

    readonly property int formFactor: Plasmoid.formFactor
    readonly property int location: Plasmoid.location
    readonly property bool showWhenNoMedia: plasmoid.configuration.showWhenNoMedia
    readonly property bool hidePlayerControlBinds: plasmoid.configuration.hidePlayerControlBindsInHoverTooltip

    readonly property font baseFont: plasmoid.configuration.useCustomFont ? plasmoid.configuration.customFont : Kirigami.Theme.defaultFont

    function updateStatus() {
        Plasmoid.status = computeStatus()
    }

    // showWhenNoMedia: always visible (user override)
    // native player: visible as soon as the app is open (player.ready)
    // browser: visible only when a media tab is open (non-empty title)
    function computeStatus() {
        if (showWhenNoMedia) return PlasmaCore.Types.ActiveStatus;
        if (!player.ready) return PlasmaCore.Types.HiddenStatus;
        if (player.isBrowser && player.title === "") {
            return PlasmaCore.Types.HiddenStatus;
        }
        return PlasmaCore.Types.ActiveStatus;
    }


    toolTipTextFormat: Text.PlainText
    toolTipMainText: player.playbackStatus > Mpris.PlaybackStatus.Stopped ? player.title : i18n("No media playing")
    toolTipSubText: {
        let text = player.artists ? i18nc("%1 is the media artist/author and %2 is the player name", "by %1 (%2)", player.artists, player.identity)
            : i18nc("%1 is the player name", "%1", player.identity)
        if(!hidePlayerControlBinds){
            text += "\n" + (player.playbackStatus === Mpris.PlaybackStatus.Playing ? i18n("Middle-click to pause") : i18n("Middle-click to play"))
            text += "\n" + i18n("Scroll to adjust volume")
            text += "\n" + (player.canRaise ? i18n("Ctrl+Click to bring player to the front") : i18n("This player can't be raised"))
        }
        return text
    }

    onShowWhenNoMediaChanged: updateStatus()

    Player {
        id: player
        sourceIdentity: {
            if (!plasmoid.configuration.choosePlayerAutomatically) {
                return plasmoid.configuration.preferredPlayerIdentity
            }
        }
        onReadyChanged: widget.updateStatus()
        onPlaybackStatusChanged: widget.updateStatus()
        onTitleChanged: widget.updateStatus()
        onIsBrowserChanged: widget.updateStatus()
    }

    compactRepresentation: Compact {}
    fullRepresentation: Full {}
}
