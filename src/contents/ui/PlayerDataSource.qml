import QtQuick 2.15
import QtQml.Models 2.3
import org.kde.plasma.private.mpris as Mpris

QtObject {
    id: root

    property var mpris2Model: Mpris.Mpris2Model {
        onRowsInserted: (_, rowIndex) => {
            const CONTAINER_ROLE = Qt.UserRole + 1
            const player = this.data(this.index(rowIndex, 0), CONTAINER_ROLE)
            if (player.desktopEntry === root.sourceName) {
                this.currentIndex = rowIndex;
            }
        }
    }

    property string sourceName: "@multiplex"

    readonly property bool ready: (mpris2Model.currentPlayer != undefined && [mpris2Model.currentPlayer.desktopEntry, "@multiplex"].includes(sourceName))

    readonly property var artists: ready ? [mpris2Model.currentPlayer.artist] : []
    readonly property string title: ready ? mpris2Model.currentPlayer.track : ""
    readonly property string playbackStatus: ready ? mpris2Model.currentPlayer.playbackStatus : ""
    readonly property bool shuffle: ready ? mpris2Model.currentPlayer.shuffle : false
    readonly property string artUrl: ready ? mpris2Model.currentPlayer.artUrl : ""
    readonly property string loopStatus: ready ? mpris2Model.currentPlayer.loopStatus : ""
    readonly property var lastSongPositionUpdate: ready ? mpris2Model.currentPlayer.position : new Date()
    readonly property int songPosition: ready ? mpris2Model.currentPlayer.position : 0
    readonly property int songLength: ready ? mpris2Model.currentPlayer.length : 0
    readonly property real volume: ready ? mpris2Model.currentPlayer.volume : 0

    readonly property bool canGoNext: ready ? mpris2Model.currentPlayer.canGoNext : false
    readonly property bool canGoPrevious: ready ? mpris2Model.currentPlayer.canGoPrevious : false
    readonly property bool canPlay: ready ? mpris2Model.currentPlayer.canPlay : false
    readonly property bool canPause: ready ? mpris2Model.currentPlayer.canPause : false
    readonly property bool canSeek: ready ? mpris2Model.currentPlayer.canSeek : false

    // To know whether Shuffle and Loop can be changed we have to check if the property is defined,
    // unlike the other commands, LoopStatus and Shuffle hasn't a specific propety such as
    // CanPause, CanSeek, etc.
    readonly property bool canChangeShuffle: ready ? mpris2Model.currentPlayer.shuffle != undefined : false
    readonly property bool canChangeLoopStatus: ready ? mpris2Model.currentPlayer.loopStatus != undefined : false

    function startOperation(op, params = {}) {
        mpris2Model.currentPlayer?.[op](...Object.values(params))
    }
}