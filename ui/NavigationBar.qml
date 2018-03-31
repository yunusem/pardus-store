import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0


Pane {
    id: navi
    visible: true
    width: navima.containsMouse ? parent.width / 7 : parent.width / 21
    height: parent.height
    z : 100
    Material.background: Material.BlueGrey
    Material.elevation: 8

    property string selectedCategory: qsTr("all")
    property variant categories: [qsTr("all"),
        qsTr("internet"),
        qsTr("office"),
        qsTr("development"),
        qsTr("reading"),
        qsTr("graphics"),
        qsTr("game"),
        qsTr("music"),
        qsTr("system"),
        qsTr("video"),
        qsTr("chat"),
        qsTr("others")]

    property variant categoryColors: ["#FFCB08","#9E9E9E", "#795548", "#FF5722", "#8BC34A", "#FF9800", "#009688", "#E91E63", "#673AB7", "#03A9F4", "#9C27B0", "#8BC34A"]

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
            categoryListModel.append({"name" : categories[i], "color": categoryColors[i]})
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

        Behavior on spacing {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }

        delegate:  Pane {
            id: categoryDelegateItem
            width: navi.width - 22
            height: navima.containsMouse ? navigationBarListView.unFoldHeight : navigationBarListView.foldHeight
            Material.background: color
            Material.elevation: 3
            Label {
                anchors.centerIn: parent
                opacity: navima.containsMouse ? 1.0 : 0.0
                color: "white"
                font.capitalization: Font.AllUppercase
                font.bold: true
                text: name

                Behavior on opacity {
                    NumberAnimation {
                        easing.type: Easing.OutExpo
                        duration: 200
                    }
                }
            }

            Behavior on height {
                NumberAnimation {
                    easing.type: Easing.OutExpo
                    duration: 200
                }
            }




            MouseArea {
                anchors.centerIn: parent
                width: categoryDelegateItem.width
                height: categoryDelegateItem.height
                onClicked: {
                    selectedCategory = name
                }
                onPressed: {
                    categoryDelegateItem.Material.elevation = 0

                }
                onReleased: {

                    categoryDelegateItem.Material.elevation = 3
                }
            }
        }

    }

}
