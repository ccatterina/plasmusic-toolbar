import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris


PlasmoidItem {
    id: widget

    Plasmoid.status: player.updateStatus()
    Plasmoid.backgroundHints: plasmoid.configuration.desktopWidgetBg

    readonly property int formFactor: Plasmoid.formFactor
    readonly property int location: Plasmoid.location
    readonly property bool showWhenNoMedia: plasmoid.configuration.showWhenNoMedia
    readonly property bool hidePlayerControlBinds: plasmoid.configuration.hidePlayerControlBindsInHoverTooltip

    readonly property font baseFont: plasmoid.configuration.useCustomFont ? plasmoid.configuration.customFont : Kirigami.Theme.defaultFont

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

    onShowWhenNoMediaChanged: player.updateStatus()

    Player {
        id: player

        // Some browsers keep the MPRIS container active even after the player tab has been closed,
        // which causes the player to be always "ready" due to the presence of the container.
        // Checking for the presence of metadata is a simple way to work around this issue.
        readonly property bool isMediaInfoSet: player.title || player.artists || player.album

        sourceIdentities: {
            if (!plasmoid.configuration.choosePlayerAutomatically) {
                const identities = plasmoid.configuration.preferredPlayerIdentity
                return identities ? identities.split(',').filter(x => x) : null
            }
            return null
        }
        onReadyChanged: {
            updateStatus();
            console.debug(`Player ready changed: ${player.ready} -> plasmoid status changed: ${Plasmoid.status}`)
        }
        onIsMediaInfoSetChanged: {
            updateStatus();
            console.debug(`Player media info changed: ${player.isMediaInfoSet} -> plasmoid status changed: ${Plasmoid.status}`)
        }

        function updateStatus() {
            if (!showWhenNoMedia && !isMediaInfoSet) {
                Plasmoid.status = PlasmaCore.Types.HiddenStatus;
            } else {
                Plasmoid.status = PlasmaCore.Types.ActiveStatus;
            }
        }

    }

    compactRepresentation: Compact {}
    fullRepresentation: Full {}
}
