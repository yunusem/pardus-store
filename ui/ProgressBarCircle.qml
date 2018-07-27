import QtQuick 2.0
import QtQml 2.2

Item {
    id: progressbarcircle

    width: 200
    height: 200

    property real value : 0
    property real maximumValue : 100
    property real arcEnd: value * (Math.PI * 1.5) / maximumValue
    property real thickness: 5
    property string colorCircle: "#2c2c2c"
    property string colorBackground: "#aaaaaa"

    onArcEndChanged: canvas.requestPaint()

    onValueChanged: {
        if(value >= maximumValue) {
            value = maximumValue
        }
    }

    Behavior on value {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        smooth: true
        text: value.toFixed(0) + "%"
        font.pointSize: thickness * 9 / 7
        color: value == 0 ? "#2c2c2c" : colorCircle
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: 135
        layer.enabled: true
        layer.smooth: true
        onPaint: {
            var ctx = getContext("2d")
            var x = width / 2
            var y = height / 2
            var start = 0
            var end = parent.arcEnd
            ctx.reset()
            ctx.beginPath();
            ctx.arc(x, y, (width / 2) - thickness / 2, 0, Math.PI * 1.5, false)
            ctx.lineWidth = thickness
            ctx.strokeStyle = colorBackground
            ctx.stroke()
            ctx.beginPath();
            ctx.arc(x, y, (width / 2) - thickness / 2, start, end, false)
            ctx.lineWidth = thickness
            ctx.strokeStyle = colorCircle
            ctx.stroke()

        }
    }
}
