import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0


ApplicationWindow {

    flags: Qt.FramelessWindowHint

    id: main
    visible: true
    width: 800
    height: 600

    title: qsTr("Pardus Market")

    // Window Properties

    property int borderWidth: 10
    property int titleBarWidth: 50
    property string windowColor: "#ffca6d"
    property string titleBarText: "Pardus Market"

    // App Info Properties

    property int appInfoSpacing: 10
    property int appInfoWidth: 100
    property int appInfoHeight: 100
    property string appInfoColor: "white"


    // Frameless App Window

    Rectangle {
        id: storeWindow
        width: main.width
        height: main.height
        color: main.windowColor

        // Title Bar

        Rectangle {
            id: titleBar
            color: "transparent"
            width: parent.width
            height: main.titleBarWidth

            // Title Bar Tittle

            Text {
                id: txtTitle
                text: main.titleBarText
                font.bold: true
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
            }


            // Drag area

            MouseArea {
                id: maTitleBar
                property variant cpos: "1,1"

                anchors.fill: parent

                onPressed: {
                    cpos = Qt.point(mouse.x,mouse.y);
                }

                onPositionChanged: {
                    var delta = Qt.point(mouse.x - cpos.x, mouse.y - cpos.y);
                    main.x += delta.x;
                    main.y += delta.y;

                }
            }
        }


        // Apps Container


        Rectangle {
            id: container
            width: parent.width - main.borderWidth * 2
            height: parent.height - main.borderWidth - main.titleBarWidth
            radius: main.borderWidth
            color: "#eeeeee"

            anchors {
                top: storeWindow.top
                left: storeWindow.left
                topMargin: titleBarWidth
                leftMargin: borderWidth
            }


            // Apps List


            Column {
                id: col1
                spacing: 5

                Row {
                    id: row1
                    spacing: 5

                    Rectangle {
                        width: main.appInfoWidth
                        height: main.appInfoHeight
                        color: main.appInfoColor

                    }

                    Rectangle {
                        width: main.appInfoWidth
                        height: main.appInfoHeight
                        color: main.appInfoColor

                    }

                    Rectangle {
                        width: main.appInfoWidth
                        height: main.appInfoHeight
                        color: main.appInfoColor

                    }

                }

            }

        }


    }

}
