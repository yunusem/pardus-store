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






    PageIndicator {
        id: indicator
        interactive: true
        count: selectedApplication === "" ? 2 : 3
        currentIndex: swipeView.currentIndex
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        onCurrentIndexChanged: {
            swipeView.currentIndex = indicator.currentIndex

            if(currentIndex == 1) {
                if(navigationBar.currentIndex == 0) {                    
                    category = qsTr("all")
                    selectedApplication = ""
                }
            } else if (currentIndex == 0) {
                category = qsTr("home")
                selectedApplication = ""
            }
        }

    }
}
