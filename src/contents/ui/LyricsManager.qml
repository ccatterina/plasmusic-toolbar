import QtQuick

QtObject {
    id: root

    property string title: ""
    property string artists: ""
    property string album: ""
    property double songLength: 0  // microseconds

    property var lyrics: []
    property bool loading: false
    property bool available: false

    // Internal: track what we last fetched to avoid duplicate requests
    property string _lastQuery: ""

    // Debounce timer to avoid spamming API on rapid track changes
    property var _debounceTimer: Timer {
        interval: 300
        repeat: false
        onTriggered: root._fetchLyrics()
    }

    onTitleChanged: _scheduleRefetch()
    onArtistsChanged: _scheduleRefetch()

    function _scheduleRefetch() {
        const query = title + "|" + artists
        if (query === _lastQuery) return
        if (!title || !artists) {
            _lastQuery = ""
            lyrics = []
            available = false
            loading = false
            return
        }
        _lastQuery = query
        lyrics = []
        available = false
        loading = true
        _debounceTimer.restart()
    }

    function _fetchLyrics() {
        const trackName = encodeURIComponent(title)
        const artistName = encodeURIComponent(artists)
        const albumName = encodeURIComponent(album)
        const durationSec = Math.round(songLength / 1000000)

        let url = "https://lrclib.net/api/get?artist_name=" + artistName
            + "&track_name=" + trackName
            + "&album_name=" + albumName
        if (durationSec > 0) {
            url += "&duration=" + durationSec
        }

        const xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return

            if (xhr.status === 200) {
                _handleResponse(xhr.responseText)
            } else if (xhr.status === 404) {
                _searchLyrics()
            } else {
                loading = false
            }
        }
        xhr.open("GET", url)
        xhr.setRequestHeader("User-Agent", "PlasMusic Toolbar (https://github.com/ccatterina/plasmusic-toolbar)")
        xhr.send()
    }

    function _searchLyrics() {
        const trackName = encodeURIComponent(title)
        const artistName = encodeURIComponent(artists)
        const url = "https://lrclib.net/api/search?track_name=" + trackName
            + "&artist_name=" + artistName

        const xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return

            if (xhr.status === 200) {
                try {
                    const results = JSON.parse(xhr.responseText)
                    for (let i = 0; i < results.length; i++) {
                        if (results[i].syncedLyrics) {
                            lyrics = _parseLRC(results[i].syncedLyrics)
                            available = lyrics.length > 0
                            loading = false
                            return
                        }
                    }
                } catch (e) {
                    // parse error, fall through
                }
            }
            loading = false
            available = false
        }
        xhr.open("GET", url)
        xhr.setRequestHeader("User-Agent", "PlasMusic Toolbar (https://github.com/ccatterina/plasmusic-toolbar)")
        xhr.send()
    }

    function _handleResponse(responseText) {
        try {
            const data = JSON.parse(responseText)
            if (data.syncedLyrics) {
                lyrics = _parseLRC(data.syncedLyrics)
                available = lyrics.length > 0
            } else {
                available = false
            }
        } catch (e) {
            available = false
        }
        loading = false
    }

    function _parseLRC(lrcString) {
        const lines = lrcString.split('\n')
        const result = []
        for (let i = 0; i < lines.length; i++) {
            const match = lines[i].match(/\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.*)/)
            if (match) {
                const minutes = parseInt(match[1])
                const seconds = parseInt(match[2])
                const ms = match[3].length === 2
                    ? parseInt(match[3]) * 10
                    : parseInt(match[3])
                const timeMs = minutes * 60000 + seconds * 1000 + ms
                const text = match[4].trim()
                if (text.length > 0) {
                    result.push({time: timeMs, text: text})
                }
            }
        }
        return result
    }
}
