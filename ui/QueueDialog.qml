import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Popup {
    id: queue
    closePolicy: Popup.CloseOnPressOutside
    //Material.background: Material.primary
    Material.elevation: 3
    width: navigationBarWidth - 12
    z: 99
    x: 6
    y: parent.height - height - 100


    property alias repeater: repeaterQueue
    property alias title: queuePopupTitle

    Behavior on y {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 600
        }
    }

    Label {
        id: queuePopupTitle
        text: qsTr("queue")
        Material.foreground: accentColor
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
                height: 24

                Label {
                    id: nameLabel
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.split(" ")[0]
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.Capitalize
                }

                Rectangle {
                    id: cancelBtn
                    visible: index != 0
                    color: "#F44336"
                    width: 24
                    height: width
                    radius: 2
                    anchors.right: parent.right
                    Label {
                        text: "X"
                        Material.foreground: "#fafafa"
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        font.capitalization: Font.Capitalize
                        font.bold: true
                    }
                    MouseArea {
                        id: cancelBtnMa
                        z: 100
                        anchors {
                            fill: parent
                        }
                        property string disqueuedApplication: ""
                        onPressed: cancelBtn.color = "#EF9A9A"
                        onPressAndHold: cancelBtn.color = "#EF9A9A"
                        onReleased: cancelBtn.color = "#F44336"
                        onClicked: {
                            var i = processQueue.indexOf(modelData)
                            disqueuedApplication = processQueue.splice(i, 1).toString()
                            var s = disqueuedApplication.split(" ")
                            var duty = s[1]

                            if (duty === "true") {
                                duty = "false"
                            } else {
                                duty = "true"
                            }

                            lastProcess = (s[0] + " " + duty)
                            updateQueue()
                        }
                    }
                }
            }
        }
    }
}
