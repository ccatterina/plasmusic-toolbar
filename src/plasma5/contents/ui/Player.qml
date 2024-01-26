import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.DataSource {
    enum LoopStatus {
        Unknown,
        None,
        Playlist,
        Track
    }

    enum PlaybackStatus {
        Unknown,
        Stopped,
        Playing,
        Paused
    }

    enum ShuffleStatus {
        Unknown,
        Off,
        On
    }

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
    readonly property int playbackStatus: Player.PlaybackStatus[getDataProp("PlaybackStatus", "Unknown")]
    readonly property int shuffle: {
        switch (getDataProp("Shuffle")) {
            case false:
                return Player.ShuffleStatus.Off;
                break;
            case true:
                return Player.ShuffleStatus.On;
                break;
            default:
                return Player.ShuffleStatus.Unknown;
        }
    }
    readonly property string artUrl: getMetadataProp("mpris:artUrl")
    readonly property int loopStatus: Player.LoopStatus[getDataProp("LoopStatus", "Unknown")]
    readonly property int songPosition: getDataProp("Position", 0)
    readonly property int songLength: getMetadataProp("mpris:length", 0)
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

    function playPause() {
        this.startOperation("PlayPause");
    }

    function seek(offset) {
        this.startOperation("Seek", {microseconds: offset});
    }

    function next() {
        this.startOperation("Next");
    }

    function previous() {
        this.startOperation("Previous");
    }

    function updatePosition() {
        this.startOperation("GetPosition");
    }

    function setVolume(volume) {
        this.startOperation("SetVolume", {level: volume});
    }

    function setLoopStatus(loopStatus) {
        const loopStatusMapping = {
            1: "None",
            2: "Playlist",
            3: "Track"
        };
        const status = loopStatusMapping[loopStatus];
        if (status) {
            this.startOperation("SetLoopStatus", {status});
        }
    }

    function setShuffle(shuffle) {
        this.startOperation("SetShuffle", {on: shuffle === Player.ShuffleStatus.On});
    }
}