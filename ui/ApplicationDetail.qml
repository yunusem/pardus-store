import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Pane {
    id:appDetail

    anchors.centerIn: parent

    width: parent.width - 10
    height: parent.height - 10
    Material.elevation: 2
    property string applicationName: selectedApplication

    property variant urls: screenshotUrls
    property int length: urls.length

    ListModel {
        id: lm
        ListElement {
            url : ""
        }
    }

    Pane {
        Material.elevation : 3
        width: parent.width * 7 / 12
        height: (width * 9 / 16) + indicator.height + 15
        anchors {
            bottom: parent.bottom
            //bottomMargin: 15
            left: parent.left
        }

        Label {
            id: indicator
            property int index: 0
            visible: urls[0] !== "none"
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                //topMargin: 5
            }

            text: (index == -1 ? lm.count.toString() : index + 1) + "/" + lm.count
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.capitalization: Font.Capitalize
            enabled: false
        }

        ListView {
            id: screenshotsLV
            interactive: true
            spacing: 15
            clip: true
            orientation: Qt.Horizontal
            width: parent.width
            height: width * 9 / 16
            anchors.centerIn: parent
            model: lm
            snapMode: ListView.SnapOneItem
            delegate: Item {
                width: screenshotsLV.width - 10
                height: screenshotsLV.height - 10
                Image {
                    id:ss
                    visible: url != "none"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: url == "none" ? "" : url
                }

                DropShadow {
                    id:dropShadow
                    visible: ss.visible
                    anchors.fill: ss
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8
                    samples: 17
                    color: "#80000000"
                    source: ss
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("no screenshot found!")
                    visible: url == "none"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.Capitalize
                    enabled: false
                }

                BusyIndicator {
                    id: imageBusy
                    anchors.centerIn: parent
                    running: url == "none" ? 0 : !ss.progress
                }
            }

            onMovementEnded: {
                indicator.index = indexAt(contentX,contentY)
            }
        }


    }

    onLengthChanged: {
        lm.clear()
        for(var i=0; i < length; i++) {
            lm.append({"url" : urls[i]})
        }
    }
}
