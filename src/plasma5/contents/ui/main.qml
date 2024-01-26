import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: widget

    Plasmoid.status: PlasmaCore.Types.HiddenStatus
    Player {
        id: player
        sourceName: plasmoid.configuration.sources[plasmoid.configuration.sourceIndex]
        onReadyChanged: () => {
            plasmoid.status = ready ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
        }
    }

    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}
}