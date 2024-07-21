import QtQuick 2.15

MouseArea {
    property int wheelDelta: 0
    signal wheelUp()
    signal wheelDown()
    onWheel: (wheel) => {
        wheelDelta += (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : -wheel.angleDelta.x)
        while (wheelDelta >= 120) {
            wheelDelta -= 120;
            wheelUp()
        }
        while (wheelDelta <= -120) {
            wheelDelta += 120;
            wheelDown()
        }
    }
}
