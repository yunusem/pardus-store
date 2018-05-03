import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Item {
    id: categoryDelegateItem
    width: navi.width - 22
    height: navigationBarListView.foldHeight


        Image {
            id: categoryIcon
            width: (parent.height >= parent.width) ? parent.width - 2 : parent.height - 2
            height: (parent.height >= parent.width) ? parent.width - 2 : parent.height - 2
            source: "qrc:/images/" + icon + ".svg"
            fillMode: Image.PreserveAspectFit
            anchors {
                verticalCenter: parent.verticalCenter
                //horizontalCenter: parent.horizontalCenter
                //horizontalCenterOffset: (width <= parent.width) ? - (parent.width - width) / 2 : 0
                left: parent.left
                leftMargin: 2
            }
            mipmap: true
            smooth: true
            antialiasing: true
        }

        DropShadow {
            id:ds
            visible: true            
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
                leftMargin: 8
                right: parent.right
                rightMargin: 2
            }
            opacity: navima.containsMouse ? 1.0 : 0.0            
            color: name === category ? "#FFCB08" : "white"
            font.capitalization: Font.Capitalize
            font.bold: name === category ? true : false
            text: name
            fontSizeMode: Text.HorizontalFit

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
            app.name = ""
            category = name
        }
        onPressed: {
            categoryDelegateItem.Material.elevation = 0

        }
        onReleased: {

            categoryDelegateItem.Material.elevation = 3
        }
    }
}
