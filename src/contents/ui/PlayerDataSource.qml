import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.DataSource {
    property string sourceName: "@multiplex"
    readonly property bool ready: (data[sourceName] !== undefined) && (data[sourceName].Metadata !== undefined)

    function getMetadataProp(key, fallback = "") {
        if (!ready || !(key in data[sourceName].Metadata)) {
            return fallback
        }
        return data[sourceName].Metadata[key]
    }

    function getDataProp(key, fallback = "") {
        if (!ready || !(key in data[sourceName])) {
            return fallback
        }
        return data[sourceName][key]
    }

    readonly property var artists: getMetadataProp("xesam:artist", [])
    readonly property string title: getMetadataProp("xesam:title")
    readonly property string playbackStatus: getDataProp("PlaybackStatus")
    readonly property bool shuffle: getDataProp("Shuffle", false)
    readonly property string artUrl: getMetadataProp("mpris:artUrl")
    readonly property string loopStatus: getDataProp("LoopStatus", "None")
    readonly property var lastSongPositionUpdate: getDataProp("Position last updated (UTC)", new Date())
    readonly property double songPosition: getDataProp("Position", 0)
    readonly property double songLength: getMetadataProp("mpris:length", 0)
    readonly property real volume: getDataProp("Volume", 0)

    readonly property bool canGoNext: getDataProp("CanGoNext", false)
    readonly property bool canGoPrevious: getDataProp("CanGoPrevious", false)
    readonly property bool canPlay: getDataProp("CanPlay", false)
    readonly property bool canPause: getDataProp("CanPause", false)
    readonly property bool canSeek: getDataProp("CanSeek", false)

    // To know whether Shuffle and Loop can be changed we have to check if the property is defined,
    // unlike the other commands, LoopStatus and Shuffle hasn't a specific property such as
    // CanPause, CanSeek, etc.
    readonly property bool canChangeShuffle: ready ? data[sourceName].Shuffle != undefined : false
    readonly property bool canChangeLoopStatus: ready ? data[sourceName].LoopStatus != undefined : false

    engine: "mpris2"
    connectedSources: []

    Component.onCompleted: () => {
        if (this.sources.find(s => s === this.sourceName)) {
            this.connectSource(this.sourceName)
        }
    }

    onSourceNameChanged: () => {
        if (this.sources.find(s => s === this.sourceName)) {
            this.connectSource(this.sourceName)
        }
    }

    onSourceAdded: (source) => {
        if (source === this.sourceName) {
            this.connectSource(source);
        }
    }

    function startOperation(op, params = {}) {
        const service = this.serviceForSource(this.sourceName);
        const operation = service.operationDescription(op);
        Object.assign(operation, params);
        service.startOperationCall(operation);
    }
}