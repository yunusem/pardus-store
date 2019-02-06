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
        anchors {
            fill: parent
            topMargin: 4
            bottomMargin: 4
        }

        color: "transparent"

        Label {
            id: notFoundLabel
            font.pointSize: 15
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("no match found")
            font.capitalization: Font.Capitalize
            Material.foreground: accentColor
            Material.theme: dark ? Material.Dark : Material.Light
            anchors.centerIn: parent
            visible: gridView.count === 0
        }

        GridView {
            id: gridView
            clip: true
            cellWidth:((width - scrollBarWidth) / 4) < 241.458   ? (width - scrollBarWidth) / 3 : Math.max((width - scrollBarWidth) / 4, 241.45833333333334)
            cellHeight: Math.max(height / 4, 234.33333333333334)
            cacheBuffer: height * 5
            visible: true
            interactive: true
            snapMode: GridView.SnapToRow
            width: parent.width - visualOffset + scrollBarWidth
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: scrollBarWidth / 2
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

            delegate: ApplicationDelegate {}
            ScrollBar.vertical: ScrollBar {
                hoverEnabled: true
                active: hovered || pressed
                anchors.left: parent.left
                anchors.leftMargin: gridView.width - scrollBarWidth - 12
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                Material.theme: dark ? Material.Dark : Material.Light
            }
        }
    }
}
