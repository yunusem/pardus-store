import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.1

Pane {
    id: pane
    property string previous
    property string current
    property int currentOption: 0
    property variant optionsModel: []
    Material.background: "#2c2c2c"
    Material.elevation: 3
    z: 92
    visible: category === qsTr("settings")
    width: (main.width * 20 / 21) - 12
    height: (main.height * 13 / 15) - 12
    anchors.centerIn: stackView
    opacity: 0.0

    onVisibleChanged: {
        if(visible) {
            opacity = 1.0
            //backBtn.opacity = 1.0
        } else {
            opacity = 0.0
        }
    }

    Behavior on opacity {
        enabled: animate
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 800
        }
    }

    Column {
        id: column
        width: parent.width / 2
        height: parent.height
        anchors {
            right: parent.horizontalCenter
        }

        spacing: 12

        Row {
            id: row1
            spacing: 12
            Label {
                text: qsTr("enable animations")
                font.capitalization: Font.Capitalize
                Material.foreground: row1Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row1Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row1Ma.containsMouse) {
                            currentOption = 0
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }

            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: animate
                onCheckedChanged: {
                    animate = checked
                }
            }

        }

        Row {
            id: row2
            spacing: 12
            Label {
                text: qsTr("update package manager cache on start")
                font.capitalization: Font.Capitalize
                Material.foreground: row2Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row2Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row2Ma.containsMouse) {
                            currentOption = 1
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }
            }
            Switch {
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                checked: updateCache
                onCheckedChanged: {
                    updateCache = checked
                }
            }

        }
        Row {
            id: row3
            spacing: 12
            Label {
                text: qsTr("Correct package manager sources list")
                font.capitalization: Font.Capitalize
                Material.foreground: row3Ma.containsMouse ? "#FFCB08":"#fafafa"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: row3Ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if(row3Ma.containsMouse) {
                            currentOption = 2
                            exp.text = optionsModel[currentOption]
                        }
                    }
                }
            }
            Button {
                id: correctBtn
                enabled: false
                anchors.verticalCenter: parent.verticalCenter
                Material.background: "#FFCB08"

                Label {
                    enabled: true
                    anchors.centerIn: parent
                    text: qsTr("correct")
                    font.bold: true
                    Material.foreground: correctBtn.enabled ? "#2c2c2c" : "#fafafa"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.Capitalize
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.horizontalCenter
        }
        height: parent.height
        width: parent.width / 2
        radius: 2
        color: "transparent"
        border.width: 1
        border.color: "#FFCB08"


        Label {
            id: exp
            width: parent.width - 24
            anchors.centerIn: parent
            height: 500
            color: "#fafafa"
            text: optionsModel[currentOption] ? optionsModel[currentOption] : ""
            font.pointSize: 15
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

    }


    Component.onCompleted:  {
        optionsModel.push(qsTr("Controls the transitions animations. If you have low performance graphic card, disabling animation may give you more comfort."))
        optionsModel.push(qsTr("Checks the system package manager's cache when Pardus-Store is started. Disabling this could speed up the starting process but if you do not use Pardus-Store often you should enable this option."))
        optionsModel.push(qsTr("Coming soon."))
    }
}
