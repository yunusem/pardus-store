import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Item {
    id: categoryDelegateItem
    width: navi.width - 24
    height: navigationBarListView.foldHeight


    Image {
        id: categoryIcon
        width: (parent.height -4 >= parent.width) ? parent.width - 4 : parent.height - 4
        height: (parent.height -4 >= parent.width) ? parent.width - 4: parent.height - 4
        source: "qrc:/images/" + icon + ".svg"
        fillMode: Image.PreserveAspectFit
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 1
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
            leftMargin: font.pointSize
            right: parent.right
            rightMargin: 2
        }
        opacity: navima.containsMouse ? 1.0 : 0.0
        color: name === category ? "#FFCB08" : "white"
        font.capitalization: Font.Capitalize
        font.bold: name === category ? true : false
        text: name
        font.pointSize: navi.height / 70
        fontSizeMode: Text.HorizontalFit


        Behavior on opacity {
            enabled: animate
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }
    }

    Behavior on height {
        enabled: animate
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
            if (stackView.depth === 3 && category === name) {
                backBtn.clicked()
            } else {
                category = name
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
