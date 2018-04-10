import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0


Pane {
    id: navi
    visible: true
    width: navima.containsMouse ? parent.width / 7 : parent.width / 21
    height: parent.height
    z : 100
    Material.background: "#2c2c2c"
    Material.elevation: 3

    property alias currentIndex : navigationBarListView.currentIndex

    MouseArea {
        id: navima
        anchors.centerIn: parent
        width: navi.width
        height: navi.height
        hoverEnabled: true
    }

    Behavior on width {
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    ListModel {
        id: categoryListModel


    }

    Component.onCompleted: {
        for (var i = 0; i < categories.length; i++) {
            categoryListModel.append({"name" : categories[i]})
        }
    }

    ListView {
        id: navigationBarListView
        height: parent.height
        interactive: true
        spacing: 17
        property int foldHeight: parent.height / count - spacing
        property int unFoldHeight: parent.height / count - spacing
        anchors.verticalCenter: parent.verticalCenter
        model: categoryListModel

        highlight: Rectangle {
            color: "transparent"

            radius: 2
            border.color: "#FFCB08"
            //z: 200
            //x:-10
            //width: 5
        }
        focus: true
        //highlightFollowsCurrentItem : true
        highlightMoveVelocity: 3600
        highlightResizeVelocity: 3600

        delegate:  CategoryDelegate {

        }

    }

}
