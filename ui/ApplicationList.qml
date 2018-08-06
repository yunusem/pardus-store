import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Page {
    property string previous
    property string current
    property int visualOffset: 84
    property int scrollBarWidth: 16
    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    GridView {
        id: gridView
        clip: true
        cellWidth: (width - scrollBarWidth) / ratio
        cellHeight: height / ratio

        visible: true
        interactive: count > 15 ? true : false
        snapMode: GridView.SnapToRow
        width: parent.width - visualOffset + scrollBarWidth
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: scrollBarWidth / 2
        model: applicationModel
        /*header: Rectangle {
            color: "transparent"
            Item {
                id: categoryLabelContainer
                width: 200
                height: 60

                Rectangle {
                    color: "#3c3c3c"
                    radius: 3
                    clip: true
                    visible: (selectedCategory !== qsTr("settings") && selectedCategory !== qsTr("home") && selectedCategory !== qsTr("all"))
                    width: parent.width - innerShadow.radius
                    height: parent.height - innerShadow.radius
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                        //verticalCenterOffset: 4
                    }
                    Label {
                        id: categoryLabel
                        text: selectedCategory
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
*/
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
        delegate: ApplicationDelegate {}
        ScrollBar.vertical: ScrollBar {
            hoverEnabled: true
            active: hovered || pressed
            anchors.left: parent.left
            anchors.leftMargin: gridView.width - scrollBarWidth - 12
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }
}
