import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Popup {
    id: queue
    closePolicy: Popup.CloseOnPressOutside
    Material.background: "#2c2c2c"
    Material.elevation: 3
    width: busy.width + processOutputLabel.width
    z: 99
    x: parent.width / 21 + 24
    y: parent.height - height - bottomDock.height - 13

    property alias repeater: repeaterQueue
    property alias title: queuePopupTitle
    Behavior on y {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 600
        }
    }

    Label {
        id: queuePopupTitle
        text: qsTr("queue")
        Material.foreground: "#ffcb08"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.capitalization: Font.Capitalize
    }

    Column {
        spacing: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height - queuePopupTitle.height
        Repeater {
            id: repeaterQueue
            model: processQueue
            Item {
                width: parent.width
                height: 18
                Text {
                    color: "white"
                    text: modelData.split(" ")[0]
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.Capitalize
                }

                Rectangle {
                    id: cancelBtn
                    width: 16
                    height: height
                    radius: 3
                    color: "#ff0000"
                    visible: index != 0
                    anchors.right: parent.right
                    Text {
                        text: "X"
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    MouseArea {
                        id: cancelBtnMa
                        z: 100
                        visible: true
                        anchors.fill: parent
                        onClicked: {
                            console.log("queue cancel clicked")
                        }
                    }
                }
            }
        }
    }
}
