import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Page {
    property string previous
    property string current
    background: Rectangle {
        color: "transparent"
        Item {
            id: categoryLabelContainer
            width: 200
            height: 60
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                color: "#3c3c3c"
                radius: 3
                clip: true
                visible: (category !== qsTr("settings") && category !== qsTr("home") && category !== qsTr("all"))
                width: parent.width - innerShadow.radius
                height: parent.height - innerShadow.radius
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    //verticalCenterOffset: 4
                }
                Label {
                    id: categoryLabel
                    text: category
                    smooth: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Material.foreground: "#ffcb08"
                    font.pointSize: 32
                    //font.capitalization: Font.Capitalize
                    font.family: pardusFont.name
                    anchors.centerIn: parent


                }
            }
        }

        InnerShadow {
            id: innerShadow
            anchors.fill: categoryLabelContainer
            cached: true
            visible: true
            smooth: true
            radius: 8
            samples: 17
            horizontalOffset: 0
            verticalOffset: 0
            color: "#ff000000"
            source: categoryLabelContainer
        }
    }

    GridView {
        id: applicationList
        clip: true
        cellWidth: applicationList.width / ratio
        cellHeight: applicationList.cellWidth * 3 / 5
        visible: true
        interactive: count > 15 ? true : false
        anchors {
            fill: parent
        }
        model: applicationModel
        add: Transition {
            enabled: animate
            NumberAnimation {
                properties: "x,y"
                duration: 200
                easing.type: Easing.OutExpo
            }
        }
        remove: Transition {
            enabled: animate
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 100
                    easing.type: Easing.OutExpo
                }
                NumberAnimation {
                    properties: "x,y"
                    to: 100
                    duration: 100
                }
            }
        }
        delegate: ApplicationDelegate { }
        ScrollBar.vertical: ScrollBar { }
    }
}
