import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ps.condition 1.0

Popup {
    id: dialogRoot
    closePolicy: Popup.CloseOnPressOutside
    Material.background: backgroundColor
    Material.elevation: 3
    width: navigationBarWidth
    z: 99
    x: 0
    y: parent.height - height - 26


    property alias repeater: repeaterQueue
    property alias title: queuePopupTitle

    Behavior on y {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 600
        }
    }

    MouseArea {
        anchors.centerIn: parent
        width: parent.width + 24
        height: parent.height + 24
        hoverEnabled: true
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
                    color: textColor
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.split(" ")[0]
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.Capitalize
                    horizontalAlignment: Text.AlignLeft
                    anchors.left: parent.left
                }

                Label {
                    id: dutyLabel
                    Material.foreground: textColor
                    Material.theme: dark ? Material.Dark : Material.Light
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    font.capitalization: Font.Capitalize
                    enabled: false
                    anchors {
                        right: cancelBtn.left
                        rightMargin: 6
                    }
                    text: index === 0 ? getConditionString(processingCondition) : (modelData.split(" ")[1] === "true" ? qsTr("remove") : qsTr("install"))
                    font.pointSize: 9
                }

                Rectangle {
                    id: cancelBtn
                    visible: index !== 0 ? true : (processingCondition === Condition.Downloading)
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
                            if(index === 0) {
                                terminateFromDialog(modelData.split(" ")[0])
                            } else {
                                disQueue(modelData.split(" ")[0])
                            }
                        }
                    }
                }
            }
        }
    }
}
