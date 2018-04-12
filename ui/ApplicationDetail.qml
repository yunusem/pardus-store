import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Item {
    id:appDetail

    anchors.fill: parent

    property string applicationName: selectedApplication

    Rectangle {
        anchors {
            margins: 10
            fill: parent
        }

        border.color: "black"
        radius: 5
    }

    Label {

        anchors.centerIn: parent
        text: applicationName + " Application DETAIL"
    }
}
