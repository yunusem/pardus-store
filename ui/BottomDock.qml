import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Controls.Material 2.0

Pane {
    width: parent.width * 20 / 21
    height: parent.height / 15
    z: 90
    anchors  {
        bottom: parent.bottom
        right: parent.right
    }

    Material.elevation: 3




    property alias pageIndicator: indicator

    PageIndicator {
        id: indicator
        interactive: true
        count: app.name === "" ? 2 : 3
        currentIndex: swipeView.currentIndex
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        onCurrentIndexChanged: {
            swipeView.currentIndex = indicator.currentIndex

            if(currentIndex == 1) {
                if(navigationBar.currentIndex == 0) {                    
                    category = qsTr("all")
                    app.name = ""
                }
            } else if (currentIndex == 0) {
                category = qsTr("home")
                app.name = ""
            }
        }

    }
}
