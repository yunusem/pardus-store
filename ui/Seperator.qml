import QtQuick 2.0

Rectangle {
    id: seperator
    color: "transparent"
    property alias lineColor: line.color
    anchors {
        left: parent.left
        right: parent.right
    }

    Rectangle {
        id: line
        color: "#2B2B2B"
        width: parent.width
        height: 1
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter
    }
}
