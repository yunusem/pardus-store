import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Item {
    id: categoryDelegateItem
    width: navi.width - 22
    height: navima.containsMouse ? navigationBarListView.unFoldHeight : navigationBarListView.foldHeight


        Image {
            id: categoryIcon
            width: 36 //navigationBarListView.foldHeight - 10
            height: width
            source: "qrc:/images/" + name + ".svg"
            anchors {
                left: parent.left
                leftMargin: 3
                verticalCenter: parent.verticalCenter
            }
            mipmap: true
            smooth: true
            antialiasing: true
        }

        DropShadow {
            id:ds
            visible: true
            //opacity: ma.containsMouse ? 0.0 : 1.0
            anchors.fill: categoryIcon
            horizontalOffset: 3
            verticalOffset: 3
            radius: 8
            samples: 17
            color: "#ff000000"
            source: categoryIcon
        }

        Label {
            anchors {
                verticalCenter: parent.verticalCenter
                left: categoryIcon.right
                leftMargin: 10
            }
            opacity: navima.containsMouse ? 1.0 : 0.0
            color: name === selectedCategory ? "#FFCB08" : "white"
            font.capitalization: Font.Capitalize
            font.bold: name === selectedCategory ? true : false
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
        id: categoryDelegateItemMa
        anchors.centerIn: parent
        width: categoryDelegateItem.width
        height: categoryDelegateItem.height
        onClicked: {
            selectedApplication = ""
            selectedCategory = name
            navigationBarListView.currentIndex = categories.indexOf(name)
            if (navigationBarListView.currentIndex == 0) {
                swipeView.currentIndex = 0
            } else {
                swipeView.currentIndex = 1
            }
        }
        onPressed: {
            categoryDelegateItem.Material.elevation = 0

        }
        onReleased: {

            categoryDelegateItem.Material.elevation = 3
        }
    }
}
