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

    ListView {
        id: screenshotsLV
        interactive: true
        spacing: 15
        clip: true
        orientation: Qt.Horizontal
        width: parent.width * 2 / 3
        height: width * 9 / 16
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }

        model: lm
        snapMode: ListView.SnapOneItem
        delegate: Item {
            width: screenshotsLV.width - 10
            height: screenshotsLV.height - 10
            Image {
                id:ss
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: url

                Component.onCompleted: {
                    console.log(url)
                }
            }

            DropShadow {
                id:dropShadow
                //opacity: ma.containsMouse ? 0.0 : 1.0
                anchors.fill: ss
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8
                samples: 17
                color: "#80000000"
                source: ss
            }

            BusyIndicator {
                id: imageBusy
                anchors.centerIn: parent
                running: !ss.progress
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
