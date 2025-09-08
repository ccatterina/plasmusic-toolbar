import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import QtQuick.Effects

// inspired by https://stackoverflow.com/a/49031115/2568933
Item {
    id: root

    enum OverflowBehaviour {
        AlwaysScroll,
        ScrollOnMouseOver,
        StopScrollOnMouseOver
    }

    property int overflowBehaviour: ScrollingText.OverflowBehaviour.AlwaysScroll

    property string text: ""
    readonly property string spacing: "     "
    readonly property string textAndSpacing: text + spacing
    property color textColor: Kirigami.Theme.textColor

    property int maxWidth: 200
    readonly property bool overflow: maxWidth < textMetrics.width
    property int speed: 5;
    readonly property int duration: (10 / speed) * 10000 * (textAndSpacing.length / maxWidth)

    property bool scrollingEnabled: true
    property bool scrollResetOnPause: false
    property bool forcePauseScrolling: false

    readonly property bool pauseScrolling: {
        if (forcePauseScrolling) {
            return true;
        }
        if (overflowBehaviour === ScrollingText.OverflowBehaviour.AlwaysScroll) {
            return false;
        } else if (overflowBehaviour === ScrollingText.OverflowBehaviour.ScrollOnMouseOver) {
            return !mouse.hovered;
        } else if (overflowBehaviour === ScrollingText.OverflowBehaviour.StopScrollOnMouseOver) {
            return mouse.hovered;
        }
    }

    property alias font: label.font

    width: overflow ? maxWidth : label.width

    Layout.preferredHeight: label.implicitHeight
    Layout.preferredWidth: width
    Layout.alignment: Qt.AlignHCenter

    HoverHandler {
        id: mouse
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    TextMetrics {
        id: textMetrics
        font: label.font
        text: root.text
    }

    PlasmaComponents3.Label {
        id: label
        text: root.overflow ? root.textAndSpacing : root.text
        color: root.textColor
        property bool animationRunning: shader.animationRunning && !shader.animationPaused
    }

    ShaderEffect {
        id: shader
        property var effectsSource: label
        property real scrollOffset
        property real clipWidth: root.width
        height: effectsSource.height
        width: effectsSource.width
        property bool animationRunning: animation.running
        property bool animationPaused: animation.paused
        property vector2d textureResolution: Qt.vector2d(effectsSource.width, effectsSource.height)

        property var source: ShaderEffectSource {
            sourceItem: {
                if (!shader.visible) {
                    return null;
                }
                return shader.effectsSource
            }
            live: true
            hideSource: shader.visible
        }
        visible: root.overflow
        fragmentShader: visible ? Qt.resolvedUrl("../shaders/scrollTextMask.frag.qsb") : ""

        NumberAnimation on scrollOffset {
            id: animation
            from: 0.0
            to: 1
            duration: root.duration
            loops: Animation.Infinite
            running: root.overflow && root.scrollingEnabled
            paused: root.pauseScrolling && running
            function reset() {
                if (running) {
                    restart()
                }
                if (running && root.pauseScrolling) {
                    pause()
                }
            }
            onDurationChanged: () => complete()
            onPausedChanged: (paused) => {
                if (paused && root.scrollResetOnPause) {
                    complete()
                    pause()
                }
            }
        }
        onWidthChanged: () => animation.reset()
    }
}
