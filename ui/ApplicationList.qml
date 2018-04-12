import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

GridView {
    id: applicationList
    clip: true
    cellWidth: applicationList.width / 5
    cellHeight: applicationList.cellWidth * 3 / 5
    visible: true
    interactive: count > 15 ? true : false    
    anchors {
        fill: parent


    }
    model: applicationModel

    add: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 200
            easing.type: Easing.OutExpo
        }
    }

    delegate: ApplicationDelegate{

    }
}
